# Jailbreaking the Kindle
This is a write-up on the development of the [Kindle 5.6.5 Webkit based jailbreak](http://www.mobileread.com/forums/showthread.php?t=265675) released in February 2016. At the time, the jailbreak opened up every Kindle with a 5.6.5 firmware release.

This document details the steps and thought processes I went through when developing the jailbreak. Ideally this will be a useful map or starting point for anyone looking at the system in the future. Most of this was written from memory after the fact, so there might be a few issues due to memory lapses. Please send any feedback or corrections to github.scott@gmail.com.

## Introduction
The goal of this jailbreak was to gain root on the system with the least amount of effort required. As such, it takes advantage of Webkit crash PoC code that already exists. The jailbreak was developed in around 100 hours during August 2015 to September 2015. Submitted to Amazon, and finally released in February after a patch came out.

## History of Kindle Jailbreaks
This section is not intended to be a complete or even entirely accurate description of previous Kindle jailbreaking efforts.

Kindles have been pretty wide open since their inception. Obviously security on an e-book reader isn't quite as critical as on other embedded systems, but Amazon does close holes that allow for code execution pretty quickly once they're public.

There have been a number of "jailbreaks" in the past. Most of the pioneering work was done by [Yifan Lu](http://yifan.lu/) although there have been a number of individual contributors over the years. The flaws are usually pretty similar and have involved the Kindle extracting untrusted packages, use of APIs that allow for root command execution through javascript, command injection due to unsanitized user input, etc.

The mobileread community has done a great job developing extended functionality of the readers. Some of the more popular packages involve an open-source alternative reader with ePub support, a plugin to change fonts, and another addon to enable custom screensaver images. Development slowed down in the past year due to better efforts by Amazon to secure the E Ink ecosystem.

## Useful Resources
* [Kindle Source Code](https://www.amazon.com/gp/help/customer/display.html?nodeId=200203720)
* [Kindle Software Updates](https://www.amazon.com/gp/help/customer/display.html/ref=ya_kindle_sb_swupdates?nodeId=200529680&_encoding=UTF8&ref_=ya_kindle_sb_swupdates)
* [Mobileread wiki](http://wiki.mobileread.com/wiki/Kindle_Touch_Hacking) is an excellent, albeit outdated, resource on Kindle internals.
* [Kindle Developer's Corner Mobileread Forum](http://www.mobileread.com/forums/forumdisplay.php?f=150) contains lots of good stuff if you go through enough of it.
* [Kindle Tool](https://github.com/NiLuJe/KindleTool) is a tool that can extract the Kindle update images Amazon hosts.
* [USBNetwork](http://www.mobileread.com/forums/showthread.php?t=225030) is a package that can be installed on jailbroken Kindles to enable SSH.

## Kindle Attack Surfaces
The Kindle operating system is Linux and runs a Java based GUI that allows the user to interact with the device. Functionality is intentionally limited to eBook activities and web browsing.

The attack surfaces are self-evident. Most become quite obvious after a bit of research into previous jailbreaks and development efforts on the Kindle.

Below are some of the more obvious avenues to explore.
* Document loading/parsing.
* The "Experimental Browser". Runs a modified Webkit build from 2010.
* Logic flaws in the Java code.
* Firmware update mechanism.
* Amazon management protocols.
* Search bar debug commands.

### Ebook loading
Fertile ground for new exploits. To my knowledge, these subsystems haven't been publicly fuzzed yet. The Kindle appears to use a PDF library provided by or developed with Foxit. Most other documents are parsed by gigantic shared objects. I didn't go down this route due to the complexity of modeling various formats, but this would be an optimal route if nothing else was found. I spent a bit of time fuzzing older versions of some of the libraries the Kindle was using with afl, but no dice.

### Experimental Browser
The most obvious canidate for exploitation. Old version of Webkit, plenty of PoC code already exists. Auditing a super old version of Webkit probably isn't a great use of anyone's time, but if we could get an existing CVE to work, fantastic!

### Logic flaws in the Java
Many embedded systems contain debugging mechanisms that aren't fully removed for release. This usually isn't true in popular consumer devices that have been out for some time, but it's always worth looking for something simple like this first.

There are hidden flags in the Java based Kindle GUI that get parsed from /mnt/us. (the user storage location exposed when the Kindle is connected over USB to a computer). Worth decompiling the Java to check for any obviously unsafe or hidden debug functionality. While there is quite a bit of hidden functionality that's exposed through this method, I didn't find much after a cursory look. Did manage to find a debug dialog that called python against a user script in the /mnt/us user store. Unfortunately, accessing the dialog would require a separate vulnerability and python being installed on the Kindle. Turns out python is only on the factory provisioning debug images and wiped during sales provisioning.

### Firmware Update Mechanism
The Kindle firmware update system has been used in the past to get code execution on the device via crafting trusted files. Downgrades are currently blocked, so definitely an interesting place to look for mistakes. Never got around to this, still an interesting avenue.

### Amazon Management Protocols
Found a reference to a system() call that looked like it could be triggered remotely with parameters. Possibly dead code, never found out how to trigger it or if it was even possible to MITM the mechanism. Would be an interesting exercise to document the APIs.

### Search Bar Debug Commands
On the Kindle filesystem, /usr/share/webkit-1.0/pillow/debug_cmds.json contains a mapping of hidden commands that can trigger script execution from the Kindle's search bar. Some of the commands are clearly stripped out in non-debug builds, but others still execute. Most importantly, these scripts all execute as root and can take parameters. Always good to audit these. The process that parses the user input and strips out potentially dangerous characters (script-executor I believe) looks good but would be worth fuzzing.

## Kindle Debugging
If we're going to try and develop an exploit on the Kindle, it helps to have some sort of debugging functionality and/or access to the actual firmware. This is somewhat of a catch-22. If you have a Kindle that's already jailbroken you can simply SSH in to a root shell using USBNetwork. On Kindles excluding the Oasis (and possibly the new Kindle 8th Generation), a serial port can be added to the device with a bit of soldering. Either way, having access to a shell makes development easier.

For the firmware, simply download the image for your device hosted by Amazon, extract it with Kindle Tool, then mount it. Something like:

```
./kindletool extract update_kindle_voyage_5.6.5.bin out
...
sudo mount -o loop rootfs.img root
```

## Analyzing the OS
The first step is one of the hardest to define. Analyze the firmware and operating system and attempt to get a very high level understanding of how it works together. Ideally after doing this you'd know a few important details about the Kindle OS. Having shell access and basic knowledge of Linux helps quite a bit here.

For example, lipc is the interprocess communication protocol that appears to wrap DBUS and is used for system actions. lipc-probe can be used to determine what properties you can get and set on the system. You can execute debug commands this way, reboot the system, set system configuration flags, pop up dialogs, etc. Here's how you reboot the system from the command line as an unprivileged user.

```lipc-set-prop -s com.lab126.contentpackd rebootDevice 0```

Another important detail is that Amazon left gdbserver on the Kindle. Great! That makes debugging crashes exponentially easier and we don't have to try and cross-compile it.

Figure out what libraries the system is using. Are they custom to Lab126 or open source? Can we get custom user input to the subsystems? Does anything look easy to fuzz? What system protections are enabled? Do system logs have any hints about potential system flaws?

How are updates verified? (public keys in /etc/uks). Is there an easy way to install a key? (not that I'm aware of)

Run through the debug search bar commands. ;dm writes system logs to the user store. Quite useful.

Once you finish a look around the operating system, you'll hopefully have a few good ideas on where to start. The most logical choice at the time was Webkit after a search for basic debug functionality that could lead to code execution failed.

## Crashing Webkit
Because the version of Webkit on 5.6.5 is so old, it's potentially vulnerable to a number of CVEs. There's no reason to spent hundreds looking for something new if we can exploit an older flaw. In this case, the hardest part of the process was done for us. Always patch your system!

There are several PoCs that crash the browser. If you watch system logs as the browser goes down, you'll get a stack trace from the mesquite process. Attach gdbserver to the process and look at the crash.

```
ps -aux | grep mesquite
gdb /usr/bin/mesquite <PID>
```

At this point, search for CVE PoC code and test it against the browser. There are quite a few examples out there, but not all of them are exploitable.

### CVE-2013-2842
[CVE-2013-2842](https://bugs.chromium.org/p/chromium/issues/detail?id=226696) is a use-after-free discovered in Webkit by Cyril Cattiaux. It was used by the Gateway 3DS team to gain code execution on the Nintendo 3DS through the browser. Also looks like it was used for some form of code execution on the Wii U. 

Both the chromium and the Gateway 3DS exploit code successfully crash the browser. I spent a bit of time adjusting the heap spray and debugging the crash remotely with GDB. With a few adjustments I got to a reliable crash where we control PC via the following:

```
ldr	r3, [r3, #632]  ; 0x278
blx	r3
```

While I lost the original register dump of the crash, it's close to the following taken during a test run of the exploit:

```
r0             0x47bb8848	1203472456
r1             0x50	80
r2             0x4d0000	5046272
r3             0xa18e0	661728
r4             0x47bb8848	1203472456
r5             0x0	0
r6             0x45dc4318	1172063000
r7             0xffffffff	4294967295
r8             0x47bb8848	1203472456
r9             0x0	0
r10            0x0	0
r11            0x0	0
r12            0xa18e0	661728
sp             0xbe8536b8	0xbe8536b8
lr             0x409ec670	1084147312
pc             0xa1e24	0xa1e24 <std::tr1::__detail::__prime_list+900>
fps            0x0	0
cpsr           0x10	16
```

r0/r4/r8 points to our heap spray, and r3 is a 32bit value loaded from the heap spray a few instructions prior. Thus, we can indirectly control PC via spraying an address. 0x278 will be added to the sprayed address, then that value will be dereferenced and branched to.

Ideally this should be enough to gain execution on the system without having to further understand the crash and heap spray.

## Exploiting the Crash
At this point, we'll need to find a pointer to a useful gadget that will get us better control of PC. The first step is to look at the mesquite process memory map in /proc/.

```
[root@kindle /usr]# cat /proc/<PID>/maps 
00008000-000a0000 r-xp 00000000 b3:01 7431       /usr/bin/mesquite
000a0000-000a2000 rwxp 00098000 b3:01 7431       /usr/bin/mesquite
000a2000-00258000 rwxp 00000000 00:00 0          [heap]
40001000-40002000 rwxp 00000000 00:00 0 
4000c000-40010000 r-xp 00000000 b3:01 13269      /usr/lib/libcjson.so
40010000-40017000 ---p 00004000 b3:01 13269      /usr/lib/libcjson.so
40017000-40018000 rwxp 00003000 b3:01 13269      /usr/lib/libcjson.so
40018000-40019000 rwxp 00000000 00:00 0 
4001e000-4003d000 r-xp 00000000 b3:01 8540       /lib/ld-2.19.so
4003d000-4003f000 rwxp 00000000 00:00 0 
4003f000-40040000 rwxp 00000000 00:00 0 
40040000-40044000 rwxs 00000000 00:04 0          /SYSV00008fb5 (deleted)
40044000-40045000 r-xp 0001e000 b3:01 8540       /lib/ld-2.19.so
40045000-40046000 rwxp 0001f000 b3:01 8540       /lib/ld-2.19.so
40046000-4004f000 rwxp 00000000 00:00 0 
4004f000-40058000 r-xp 00000000 b3:01 2979       /usr/lib/libconnection-utils.so
40058000-40060000 ---p 00009000 b3:01 2979       /usr/lib/libconnection-utils.so
40060000-40061000 rwxp 00009000 b3:01 2979       /usr/lib/libconnection-utils.so
...
```

If you reload the process and dump the maps each time, you'll note that the libraries mapped have changing addresses, while the /usr/bin/mesquite addresses remains the same. Luckily, the mesquite process was not compiled as position independant. As such, it remains in the same address space each execution and is an excellent target to return into. If mesquite had been compiled PIE, ASLR would have rendered this a bit harder as we'd have to search for some sort of information leak.

Also note that the heap and a pretty good chunk of other segments are marked as rwx.

### Mesquite Static Analysis
We can get the processor to dereference a value and jump to the result. Because Mesquite isn't PIE, we can search the small address space for interesting addresses to return to.

I wrote a simple python script that would take all constant words in the code segment and check to see if they could be interpretted as "pointers" to the same area of code. If it happened to look like a pointer, we could spray that value (minus 0x278) and pass execution to somewhere in the same code segment. The script then dumped out where execution would go to and a list of ten or so instructions at that address.

The only interesting looking "gadget" I found was the following:
```
(gdb) disas 0x9c94 0x9c9c
Dump of assembler code from 0x9c94 to 0x9c9c:
0x00009c94:     strplb  r5, [r8], sp, asr #23 -- NOP as N==1
0x00009c98:     orrhi   pc, r8, #18688  ; 0x4900 -- These flags are set. Runs!
```
There happened to be a word that gets mapped into the code segment that when dereferenced will take us to 0x9C94.

In our case, the first instruction won't execute due to the PL condition code on the instruction. ([Here's](https://community.arm.com/groups/processors/blog/2010/07/16/condition-codes-1-condition-flags-and-codes) a good introduction to ARM condition codes.) The orrhi instruction will as the corresponding flags are set, and we end up moving PC somewhere further into the address space. In roughly one out of ten executions, this gets us code execution to our heap spray. I prototyped a simple exit call via jumping to libc.

For a jailbreak, 10 reloads before code execution isn't bad at all. If we went down this route, the reliability could probably be improved through better understanding of the heap spray & CVE. The issue is that the word pointer to the interesting gadget only happens to exist on the Paperwhite 2 firmware.

We can do better.

### Mesquite Dynamic Analysis
The code segment at 00008000-000a0000 doesn't appear to be too helpful. What about 000a0000-000a2000 and 00a2000-00258000? The processes's heap might have something interesting written to it during execution.

For this step, I connected IDA Pro to gdbserver and manually walked through the non ASLR'd address space. One interesting find were multiple pointers to the IP address of the webserver I was hosting to service the POC code. I figured there might be a small chance I could connect the Kindle to a network with a custom IP address that happened to decode to a useful set of PC modifying instructions.

Thankfully, the discovery was better than that. When loading a URL in the Kindle browser, the pointer was updated to the full ASCII domain. The buffer also dynamically resized itself to whatever the user typed in the address bar.

We can now spray the address of the buffer that appears to mirror the address bar and get code execution to a URL.

### Alphanumeric ARM Shellcode
Alphanumeric ARM shellcode is a solved problem. See [Alphanumeric RISC ARM Shellcode] in Phrack 66 by Yves Younan and Pieter Philippaerts. There's an excellent example shellcode at the bottom of the article that executes a binary in the root filesystem. Unfortunately, the Kindle is EABI instead of the OABI the target shellcode was written for. The cache flush mechanism will have to change quite a bit, and the actual execve will need to take arguments. Because the user-store on the Kindle is mounted noexec, we can't simply execve a shell script. We need to execve /bin/sh and pass our script as an argument.

Writing the shellcode was probably the most time consuming part of the jailbreak process. It's a bit hard to intuitively grasp writing code using such a small subset of instructions and having to heavily rely on XOR operations.

Another challenge in developing the shellcode involves cache flushing. The ARM shellcode needs to modify itself to generate instructions not normally expressable in the alphanumeric ARM instruction set then flush the cache so they're actually executed. Debugging caching is tough. Walking through the shellcode with GDB will always succeed even if the cache flush operation fails. However, executing the shellcode will fail if GDB isn't attached and the cache flush fails. Tricky to get right and debug.

The [resultant shellcode](https://github.com/sgayou/kindle-5.6.5-jailbreak/blob/master/shellcode.s) compiles to 
```
bbbb80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR00OB00OR00SU00SE9PSB9PSR0pMB80SBcaCPcAOPqAGYcACPyPDReaOPeaFPeaFPeaFPeaFPeaFPeaFPeaFPR0FUS0FUT0FU803R9pCRPP7R6PCBBP3BlP5RHPFUVP3RAP5RFPFUGpFUx0GRx0CRx0CRcaFPcaFPaP7RAP5BqPFE8p4B0PMRGA5X8pGRdQDPORuR0P5BO2UB4PERev7P2p7R0p7R0P5RAAAO8P4BaaOP000QxFR058FBvB0G0bin0sh00mnt0us0jb00M0b8QCz1s9BTz1o9BTQCa129JBRBaCBTz1v9BTz1v9BTz1v9BTz1w9BTaC0119OBaCA169OCjFaCPPz1v9z0r8PPz1v9TPQBIBr0z8bC00
```

hexblog wrote an [article](http://www.hexblog.com/?p=111) on how to use IDA Pro and QEMU to simulate/RE the example shellcode in the Phrack article. It's a good way to watch what's going on during execution.

### Staging the Exploit
We're almost done with taking advantage of the crash. Still, there's one last issue. To trigger the exploit, you need to load a webpage containing the crash. Loading a webpage will update the contents of the address bar buffer with the URL of the page.

We get lucky again. If we stage the shellcode first (by requesting the user clicks a link with the target being the shellcode) then have them navigate to a shorter URL, the new URL will be overwrite part of the shellcode and null terminate itself. The rest of the shellcode will remain intact.

If we control DNS on the network the Kindle is connected to, we can set the server hostname to a known value. We need to choose a hostname that will overwrite the staged buffer in such a way that a NOP operation is created. I arbitrarily chose this as "a". I then chose an instruction that could be overwritten by "a\0" and would turn into another operation that wouldn't cause any sort of system fault.

The shellcode starts with "bbbb" to enable this. We then need to man-in-the-middle (or control DNS on the local network) in such a way that "a" points to our exploit code. The user populates the buffer with shellcode by clicking a link, navigates back (to "a"), then clicks another link to trigger the exploit. The buffer ends up looking similar to below (older version of the shellcode than the current one). Note "a", a null terminator, then the rest of the shellcode.

```
(gdb) x/s *0xa2120
0x1f8244:        "a"
(gdb) x/2s *0xa2120
0x1f8244:        "a" ; Shellcode follows the null terminator.
0x1f8246:        "bbbbbbbbbb80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR"...
```

"bbbb...", which is a RSBVS, becomes "a\0bb..." which is also safe to execute.

#### Exploit Staging Addendum
It turns out that there are quite a few combinations of URLs that happen to decode to pseudo NOPs and are safe to execute in the above manner. I originally released the jailbreak with complicated instructions involving DNS manipulation. The plan was to release the jailbreak for more advanced users, then release a simpler version a few days later involving a custom registered domain I could verify would execute the shellcode correctly. This would bypass the need for any DNS hijinks.

A few days after the initial release, a few other individuals uploaded the exploit to various websites. Most didn't work and just triggered the browser to crash, but a few actually executed the shellcode correctly. It turns out a few users uploaded the exploit to domains that happened to decode to ARM effective NOP sleds to the actual payload. Cool!

##### Kindlefere Hosting Analysis
Kindlefere.com uploaded the jailbreak to a jb subdirectory. Here's what ended up happening:

```
Kindlefere:
(gdb) x/2s *0xa2120  
0x1c449c:	 "kindlefere.com"
0x1c44ab:	 "R80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR80AR00OB00OR00SU00SE9PSB9PSR0pMB80SBcaCPcAOPqAGYcACPyPDReaOPeaFPeaFPeaFPeaFPeaFPeaFPeaFPR0FUS0FUT0FU803"...
```
Looks like the buffer only contains the FQDN? Nevertheless, this disassembles to:

```
(gdb) disas *0xa2120 *0xa2120+0x24
Dump of assembler code from 0x1c449c to 0x1c44c0:
0x001c449c:	strvsbt	r6, [lr], #-2411
0x001c44a0:	strvsb	r6, [r6, #-1388]!
0x001c44a4:	teqvs	lr, #478150656	; 0x1c800000
0x001c44a8:	andpl	r6, r0, #7104	; 0x1bc0
0x001c44ac:	subpl	r3, r1, #56	; 0x38
0x001c44b0:	subpl	r3, r1, #56	; 0x38
0x001c44b4:	subpl	r3, r1, #56	; 0x38
0x001c44b8:	subpl	r3, r1, #56	; 0x38
0x001c44bc:	subpl	r3, r1, #56	; 0x38
End of assembler dump.
```

The VS flag doesn't appear to get set during the crash. As such, the stores/teq doesn't run and we end up at the start of the shellcode.

##### Local Execution

Finally, there was one more development a few weeks later. A mobileread user determined that you could actually load the exploit code in the browser from the local user store. If you put the exploit code in the Kindle user share and navigated to file:///mnt/us/index.html in the Kindle browser, it would reliably execute. This bypassed the need to manipulate DNS and/or trust third parties hosting the exploit code.

The "file:///mnt/us/index.html" trick was interesting. I stepped through an execution of it in GDB and discovered that file:///mnt/us/index.html never got written to the address bar buffer. As such, the shell code gets loaded and executed without being altered or overwritten. This points to my understanding of the buffer I'm using being incomplete. Either way, it was a great find.

### Shell Script Execution
At this point we can trigger the browser to execve /bin/sh /mnt/us/jb. This gives up shell execution as the browser user and group which is id=9000(framework) gid=0(root). We still need some form of root escalation before we're done.

There was an older prvilege escalation method that involved writing a file to /var/local/system that would be sourced by another script running as root during boot. Unfortunately, the browser user was unable to write to this file due to permissions issues.

My first discovery was that after a system reset on first boot the browser user could move the local directory inside of /usr and create new directories. After a first reboot, the directory permissions changed and this attack was no longer possible. Here's an entry from the JSON file that has the debug command to script mapping.

```";sbx" : "/usr/local/bin/sandbox.sh"```

;sbx is one of the scripts that doesn't exist on the firmware. We simply move /usr/local to /usr/local.bak and then create /usr/local/bin/sandbox.sh. Running ;sbx in the search bar then runs the script our browser user created as root. Done.

Once I got root escalation, I looked into how to install the developer key mobileread forums users were using to create custom packages. It's as simple as writing a key to /etc/uks.

I checked the permissions of /etc/uks to make sure I matched the correct permissions of the key, and saw the following:

```
 [root@kindle /]# ls -la /etc/uks/
 drwxrwxr-x 2 root root 1024 Sep 23 16:49 
```

Whoops! Didn't even bother looking for something this simple. Turns out the browser can already read/write/execute to pretty much every folder on the system due to a permissions failure. I'm unsure why group root has such permissions, but I'll take it.

### Filesystem Remount

There's one more issue. If we try to write the key to the filesystem during shell script execution, we'll get an error that the filesystem is mounted read-only. We need a way to remount the filesystem as RW. This can be done by root but cannot be done by the framework user.

There's a few possible ways to tackle this:

1. Use the previous root escalation and run mntroot rw. Not ideal as this would require a hard reset of the Kindle and more user intervention
2. Hard reset the system. There's another issue where the file-system stays mounted RW after the first boot. After a reboot, it will be mounted RO. Same issue as before.
3. If we search the firmware for "mntroot rw", we'll see that it gets called in a script that runs when the user executes ;fc-cache from the search bar.

#### fc-cache Timing Attack
It appears that Amazon was experimenting with implementing custom font support at one point but never enabled the feature. They left the ;fc-cache command as an artifact.

Abbreivated contents of fc-cache.sh:

```
echo "Making rootfs read-write"
mntroot rw
...
echo "Running fc-cache. This can take a long time.“ # 2+ minutes.
fc-cache –r
...
mntroot ro
```

Should be obvious. If we can get our script to write the key between mntroot rw and mntroot ro, we're done. Turns out fc-cache -r takes over two minutes to run, so it's the easiest race condition in the world to hit.

And we're done. Here's the [final script](https://github.com/sgayou/kindle-5.6.5-jailbreak/blob/master/jb) with a few qualitiy of life improvements to prompt the user to run ;fc-cache at the correct time.

After the release I discovered a way to programatically execute debug search bar commands from the command line. There's a debug command execution field you can trigger from lipc. This would have made the jailbreak slightly less confusing as a few people struggled with what "Run ;fc-cache in the search bar" meant.

## In Conclusion
The mesquite binaries were the same on all Kindles at the time. The jailbreak happened to work on every Kindle with a 5.6.5 firmware release with no changes required. Lucky!

I submitted the jailbreak package to Amazon Security around the twenty second of September. They had a new version of the Kindle OS with a patch in February. Released a few days after the patch. Always a bit scary to see how many people will happily execute slightly obfuscated exploit code without reverse engineering it first.

For the fix, Amazon did quite a few things. They sandboxed the browser, fixed the permissions issue, removed fc-cache.sh, and most likely patched Webkit. Webkit still crashes when executing the PoC. Unsure if that's because of the process running out of memory or some other issue.

Embedded targets are a heck of a lot of fun to break. The security is usually a bit more lax and having to understand each new embedded system is always a blast.

Thanks to Lab126 Security, Cyril Cattiaux, Gateway 3DS, Yves Younan, Pieter Philippaerts, [NiLuJe](https://github.com/NiLuJe), and [Yifan Lu](http://yifan.lu/) for previous Kindle work.