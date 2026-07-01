# Snapshots and rolling back

[Video Source](https://youtu.be/d-CafjZf2M4?is=Kog72fECEZmeLmGd)

## Creating a partition table

In the **Installation** method section, during the setup wizard of Fedora, click on 3 dots in top right corner and choose **Launch storage editor**.

Choose your prefered disk, and click on **Create partition table**:
- Partitioning: `GPT`
- Overwrite: this perfomes a more secure wipe, but it takes more time.

***Warning***! This will erase everything on the selected disk.

Now click on **Initialize**.

## Advanced Disk Partitioning (Btrfs)


**Btrfs** is a modern file system that allows you to create a **single main partition** that can contain *multiple subvolumes*, making it versatile for managing storage. It supports features like snapshots, compression, and dynamic resizing, which can enhance performance and data management.


On the *Free Space* section, click on **Create partition**:

### EFI System Partition

This type of partition is used by **UEFI** (Unified Extensible Firmware Interface) firmware and stores stores
- boot loaders or kernel images
- device drivers files for hardware devices present in a computer and used by firmware at boottime
- system utilty programs that are inteneded to be run before an OS is booted
- data files such as error logs etc 

|  Setting   |  Value   |
| ------- | --------- |
| name | `ESP` |
| Mount Point | `/boot/efi` |
| Type | `EFI system partition` |
| Size | `1.0737 GB` |

### Main BTRFS Partition

This partition will be used as the main partition of the disk.
 
|  Setting   |  Value   |
| ------- | --------- |
| name | `Fedora` |
| Mount Point | blank |
| Type | `BTRFS` |
| Size | all the remaining space |

*OBS*: We leave the mount point blank because we will create subvolumes later



## Creating BTRFS Subvolumes

Instead of splitting our disk into fixed partitions (like in `ext4`), BTRFS uses **subvolumes**. They act like directories that share the same storage pool, meaning they grow and shrink dynamically. You don't have to worry about allocating fixed sizes in advance.

To create them, click on the three-dot menu on the top-level **Fedora** volume you just created, and select **Create subvolume**. We will create these one by one.

### 1. Core System Subvolumes

These two are the most important. They will be actively monitored by our snapshot tool (Snapper).

**Root (System Files)**
Where your entire operating system, binaries, and configurations live.
| Setting | Value |
| :--- | :--- |
| Name | `root` |
| Mount Point | `/` |

**Home (Personal Data)**
Where your documents, downloads, and user configurations are stored.
| Setting | Value |
| :--- | :--- |
| Name | `home` |
| Mount Point | `/home` |

### 2. Exclusion Subvolumes

The rest of the subvolumes are created to **exclude** specific directories from our root snapshots. Things like temporary files, caches, and Flatpaks change constantly and are quite large. By giving them their own subvolumes, we keep our system snapshots clean, small, and fast.

---
**Opt (Third-party Apps)**
Optional, but recommended for apps  installed outside the standard package manager.
| Setting | Value |
| :--- | :--- |
| Name | `opt` |
| Mount Point | `/opt` |

---

**Cache (Temporary App Data)**
Stores temporary application data like package metadata. Does not need to be snapshotted.
| Setting | Value |
| :--- | :--- |
| Name | `cache` |
| Mount Point | `/var/cache` |

---

**Logs (System Logs)**
Keeps system and boot logs separate so that if you roll back a broken system, you can still read the error logs to see what caused the crash.
| Setting | Value |
| :--- | :--- |
| Name | `log` |
| Mount Point | `/var/log` |

---

**Spool (Queued Data)**
Used for constantly changing queued data like print jobs or mail.
| Setting | Value |
| :--- | :--- |
| Name | `spool` |
| Mount Point | `/var/spool` |

---

**Tmp (Persistent Temporary Files)**
For temporary files that need to persist across reboots. (Note: `/tmp` is cleared on reboot, but `/var/tmp` is stored on the disk).
| Setting | Value |
| :--- | :--- |
| Name | `tmp` |
| Mount Point | `/var/tmp` |

---

**Containers (Docker/Podman)**
Stores container images. Prevents heavy container data from bloating system snapshots.
| Setting | Value |
| :--- | :--- |
| Name | `containers` |
| Mount Point | `/var/lib/containers` |

---

**Flatpak (Sandboxed Apps)**
Crucial for keeping your Flatpak apps and games safe when rolling back the core operating system.
| Setting | Value |
| :--- | :--- |
| Name | `flatpak` |
| Mount Point | `/var/lib/flatpak` |

---

**GDM / SDDM / Plasmalogin (Display Manager)**
Keeping this separate ensures your login screen doesn't freeze when booting into a read-only snapshot.
| Setting | Value |
| :--- | :--- |
| Name | `plasmalogin` |
| Mount Point | `/var/lib/plasmalogin` |

---

**Libvirt (Virtual Machines)**
Optional. Used if you plan to run KVM/QEMU virtual machines.
| Setting | Value |
| :--- | :--- |
| Name | `libvirt` |
| Mount Point | `/var/lib/libvirt` |

---

Once all subvolumes are created, click **Return to installation** to validate the storage layout.


## Enabling Compression (ZSTD)

Check if all the subvolumes are mounted where we want them
```bash
lsblk -p /dev/nvme0n1
```
- `lsblk` = list block devices
- `-p` = print full divice path
- `/dev/nvme0n1` = the device

List all the btrfs volumes:
```bash
sudo btrfs subvolume list /
```
- `btrfs`= toolbox to manage btrfs filesystems
- `subvolume list` = list subvolumes and snapshots in the files system
- `/` = path


If we run 
```bash
cat /etc/ftstab
```
we will see that the compression tab is missing. If we had used the default fedora installation method, this option would have been added automatically, but since we used the custom installation, its wasnt included. This option reduces disk usage.


To enabel compression we run the following commmand:
```bash
sudo sed -i.bkp '/ btrfs / s/subvol=[^ ,]*/&,compress=zstd:1/' /etc/fstab
```
- `sed` = stream editor for filtering and transforming text
- `-i.bkp`: edit the file directly in its location (`-i`) and create a copy with the suffix `.bkp` if we want to revert the changes (i.e. `etc/fstab.bkp`)
- `/ btrfs / ` = a filter for the `sed` command; procces online the lines that contain the word `btrfs` (aka edit online the btrfs file systems)
- `s/subvol=[^ ,]*/&,compress=zstd:1/'` = substituion instruction
    - search the parameter `subvol`
    - `&` the initial text found
    - `,compress=zstd:1` add this text imediately after
    - `etc/fstab` the file we edit (FileSystem Table)


Reboot and ven verify if compression is active:
```bash
mount | grep btrfs
```




