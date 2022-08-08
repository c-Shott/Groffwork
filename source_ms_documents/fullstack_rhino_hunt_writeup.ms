.so <relative filepath to groff_macros_file>
.TL
Rhino Hunt Lab
.AU
Connor Shott
.DA
08.07.2022

.SH
Senario:
.PP
The city of New Orleans passed a law in 2004 making possession of nine or more unique rhinoceros images a serious crime. The network administrator at the University of New Orleans recently alerted police when his instance of RHINOVORE flagged illegal rhino traffic. Evidence in the case includes a computer and USB key seized from one of the University's labs. Unfortunately, the computer had no hard drive. The USB key was imaged and a copy of the dd image is on the CD-ROM you have been given.
.PP
In addition to the USB key drive image, three network traces are also available. These were provided by the network administrator and involved the machine with the missing hard drive. The suspect is the primary user of this machine, who has been pursuing his Ph.D. at the University since 1972.
.SH
Provided Evidence:
.RS
.bl
c0d0093eb1664cd7b73f3a5225ae3f30 *rhino.log
.bl
cd21eaf4acfb50f71ffff857d7968341 *rhino2.log
.bl
7e29f9d67346df25faaf18efcd95fc30 *rhino3.log
.bl
80348c58eec4c328ef1f7709adc56a54 *RHINOUSB.dd
.RE
.SH
Tasks
.RS
.bl
Who gave the telnet/ftp account
.bl 
what is the username and password for the account
.bl
what relevant file transfers appear in the network traces
.bl
what happened to the computer hard drive and where is it
.bl
what happened to the USB key
.bl
what is recoverable from the DD image of the USB key
.bl
is there any evidence connecting the USB key and network traces
.RE
.SH
Steps Taken
.PP
This section will explore how the answers were obtained and the process for solving this lab. Please skip to the next section for just the answers.
.NH
Resources
.PP
To complete this lab, some resources are necessary.
.RS
.bl
The SIFT workstation available
.pdfhref W -D https://digital-forensics.sans.org/community/downloads -A . here
.bl
The evidence zip file: 
.pdfhref W -D https://cfreds-archive.nist.gov/dfrws/DFRWS2005-RODEO.zip -A . download
.bl
Install fcrackzip on the SIFT workstation
.bl
Install the SecLists repo from 
.pdfhref W -A . https://github.com/danielmiessler/SecLists
.RE
.NH
Getting Started
.PP
This walk-through assumes that the SIFT workstation is up and running. Information on setup and installation can be found 
.pdfhref W -A https://www.1337pwn.com/how-to-install-sans-sift-workstation-on-virtualbox-easily/ -A . here
.NH 2
Unzipping The File
.PP 
In the terminal, navigate to 
.CW ~/Desktop/cases
and run
.CW "mkdir Rhino"
and
.CW "wget <evidence file URL>".
finally, run 
.CW "unzip DFRWS2005-RODEO.zip" 
and four files will be extracted to the working directory.

\X"pdf: pdfpic ./images/unzipped_directory.pdf -C 400"



.NH 2
RHINOUSB.dd
.PP
The first item of interest is the 
.UL RHINOUSB.DD
file.
Running 
.CW "file RHINOUSB.dd"
gives the following output

\X'pdf: pdfpic ./images/rhinodd_file_out.pdf -C 400'





.PP
We can see that it is a boot sector device that has data on it. That data can be recovered in a couple of ways, I am going to use the
.CW photorec 
tool.
.NH 3
What Is Photorec
.PP
Photorec is a recovery tool used to recover file from hard disks, digital cameras, and CD-ROM devices. Full documentation can be found on the 
.CW man
page, or at their 
.pdfhref W -D https://www.cgsecurity.org/wiki/PhotoRec -A . website 
We are going to use photorec since it outputs more information, although as we will see, not all of it is helpful.

.PP
Another tool that can be used is 
.CW foremost 
which is simpler to use, but does not give as much data in this situation.
.NH 2
Using photorec
.PP
Using photorec from the command line is easy, and it is already installed on the SIFT workstation. To invoke it just type
.CW "photorec RHINOUSB.dd"
and this screen will appear

\X'pdf: pdfpic ./images/photorec_RHINOUSB.pdf -C 400 175 550'
.sp 15
.PP
Pressing 
.CW enter
on the highlighted option prompts us to choose a partition. We want the full disk

\X'pdf: pdfpic ./images/photorec_RHINOUSB_s2.pdf -C 400 175 550'
.sp 15
.PP
the next screen asks for the file system type, select
.CW ext2/ext3
and hit enter. Next, photorec wants a directory to output the recovered files to. Leaving it on the "." directory will make a new file in the current directory, which for us is
.CW ~/Desktop/cases/rhino .
Hitting 
.CW C
leads us to a report screen saying 134 files have been recovered. Since we never gave a name to the output file, it is by default 
.CW recup_dir.1 .
Lets take a look at what was recovered!
.NH 2
Photorec Output

\X'pdf: pdfpic ./images/recup_dir_1.pdf -C 400 175 550'
.sp 15
.PP
Along with a TON of similarly named text files, we find some .jpg files, and some gifs, and even a Microsoft Word document. The images have been redacted so you can experience their beauty for yourself, and they may not all be rhinos...
.bp
.PP
Looking at one of the .txt files at random, it is hundreds of lines all with
.CW CHARLIE
on them. Inspection of more reveals that they are all long and all the lines contain the first two. Only two files break this, and they appear first in the file order. Opening up the Microsoft Word document shows that it is a diary of some form. There are a couple of interesting points towards the bottom.
.sp 0.2
\X'pdf: pdfpic ./images/word_doc1.pdf -C 500 100 550'
.sp 9
.PP
This answers two of our tasks! What happened to the USB drive, and where is the hard drive. There is also reference to a
\*Q
gnome
\*U
account that someone named 
\*Q
Jeremy
\*U
supplied the writer with. That's a good start! Lets take a break from the dd image and look at the log files, beginning with rhino.log.
.NH
Rhino.log
.PP
One of the first things to do when looking at the first of the 
.CW .log
files is to determine exactly what kind of log file we are working with. The easiest way to do this is by running the 
.CW file
command on the listed file. 
.sp .1
\X'pdf: pdfpic ./images/filetype_rhino1log.pdf -L 500'
.sp 2
.PP
So it's a pcap file! That means we can use Wireshark to process it.
.NH 2
What is Wireshark
.PP
Wireshark is a network traffic analysis tool. It will let us look in depth at network traffic, and see data that was sent. Further documentation can be found at their 
.pdfhref W -D https://www.wireshark.org/docs/ -A . website
.NH 2
Findings in Rhino.log
.PP
One of the first places I check when looking at a pcap is the 
\*Q 
Protocol Hierarchy
\*U
found under the statistics section of the Wireshark ribbon. 
.sp 0.5
\X'pdf: pdfpic ./images/protocall_hierarchy_rhino1.pdf -L 400'
.sp 4
.PP
It looks like there was some FTP action going on, let's take a closer look at that by applying a 
.CW "ftp contains rhino"
filter since we know we are looking for rhinos.
.sp 0.5
\X'pdf: pdfpic ./images/fto_contains_rhino.pdf -L 500 '
.sp 15
.PP
Great, a lead! So, there are at least two files in this log that are of interest. Let's take a look at other packets, so we can try to get more information. Sorting by 
.CW ftp-data
leads to a good number of packets that appear to be from the above 
\*Q
rhino1
\*U
and
\*Q
rhino3
\*U
jpg files. Lets take a closer look. Right-clicking on packet 
.CW 1551
and selecting
.CW "follow tcp stream"
takes us to some gibberish that from the first few lines appears to contain something having to do with Adobe Photoshop.
.sp 0.5
\X'pdf: pdfpic ./images/packet_1551_stream.pdf -C 400 175 550'
.sp 15
.PP
Lets see what we can do with this. Change the data to 
\*Q
show as raw
\*U
, then save as 
\*Q
rhino1.jpg
\*U
in a directory of your choosing. To keep things compartmentalized, I made a 
\*Q
rhino1log
\*U
folder in the working directory. If all goes well there will be an image in your file! Let's go back to the 
.CW ftp-data
filter and do the same thing for the 
\*Q
rhino3.jpg
\*U 
file. It looks like the first ftp-data packet containing rhino3 is packet 1654. Following the same process of right click, follow tcp stream; then showing as raw data shows this:
.sp 0.5
\X'pdf: pdfpic ./images/packet_1654_raw.pdf -C 400 175 550'
.sp 15
.PP
saving the stream as 
\*Q
rhino3.jpg
\*U
into the same directory as the 
\*Q
rhino1.jpg
\*U
also shows an image!
.sp 10
.PP
We have found a good chunk of info so far in this first log, but there is more! lets go back to the 
.CW ftp-data
filter and see if there is anything else of note. Look at that, there is!
.sp 0.5
\X'pdf: pdfpic ./images/ftpdata_contraband.pdf -L 400'
.sp 10
.PP
lets to the same process for this 
\*Q
contraband.zip
\*U
file that was transferred. This time we are following the stream for packet 5652, and saving as to the same directory as the jpg files. 
.NH 2
Contraband.zip
.PP
We have another successful file recovery! This time it is a zip file. It looks like it contains another rhino image, but it is password protected.
.sp 0.5
\X'pdf: pdfpic ./images/extract_attempt_1.pdf -C 400 175 550'
.sp 15
.NH 3
Zip Password Cracking
.PP
Remember back at the start I had the SecLists repo installed, along with a tool called 
.CW fcrackzip
? Well this is where they are going to come in handy! 
.CW fcrackzip
is a tool used to break passwords for zip files. It takes in a dictionary, which we will pull from the SecLists repository. I used the
\*Q
500-worst-passwords.txt
\*U
file from the password folder in SecLists. With that we are ready to get cracking!
.PP
The basic syntax for 
.CW fcrackzip
is
.DS C
.CW "fcrackzip -u -D -p <dictionary path> <file to crack>" .
.DE
The dictionary path is finniky sometimes, but always works for the current directory which is why we copied the password file. Running this command gives us the password fairly quick.
.sp 0.5
\X'pdf: pdfpic ./images/fcrackzip_monkey.pdf -L 400'
.sp 5
.PP
putting this password into the extract window lets us grab the 
\*Q
rhino2.jpg
\*Q 
giving us three rhino images from this log! Where are these images being transferred from though? Lets go back to the pcap and do some more digging.
.NH 2
The Rest Of The Pcap
.PP
Lets start by taking a look at another piece of the pcap that hasn't been touched yet, the tcp packets. Filtering by 
.DS C
.CW "tcp contains rhino"
.DE
provides a number of packets to look at. Some of them, like packet 27 shows a login for a 
\*Q
hugerhinolover@hotmail.com
\*U
but this doesn't seem to lead to anything interesting. Further down in packet 2600, there is a 
.CW "HTTP POST"
request linked to that rhinolover email. The body and recipient are of interest to us.
.sp 0.5
\X'pdf: pdfpic ./images/rhino_email.pdf -C 400 175 550'
.sp 15
.PP
So it looks like the user John is using an account to access and upload more rhino material. Let's see if we can find anything else related to this account in the pcap. Sorting by 
.DS C
.CW "tcp contains gnome" 
.DE
gives 
.CW TELNET
and 
.CW ftp
packets. The ftp ones are exactly what we were looking for.
.sp .5
\X'pdf: pdfpic ./images/tcp_contains_gnome.pdf -L 400'
.sp 10
.PP
Gnome is a username, and there is a simple password associated with it sent in plain text. How nice for us! Further down, in packet 5633 there are the beginning of some failed password reset attempts. That is a bunch of information pulled from the first log file, and everything of use I was able to find in it. Let's move on now to the second log file.

.NH
Rhino2.log
.PP
Once again, running the 
.CW file
command on rhino2.log reveals that it is another pcap. Loading it up in Wireshark and looking at the protocol hierarchy shows that there were some interactions over IMAP, but most of the packets are HTTP.
.sp .5
\X'pdf: pdfpic ./images/rhino2_hierarchy.pdf -L 400'
.sp 8
.PP
Lets use some search terms identified in the last pcap, starting with the
\*Q
gnome
\*U
username. Running 
.DS C
.CW "http contains gnome"
.DE
gives us six packets.
.sp 0.5
\X'pdf: pdfpic ./images/http_contains_gnome_rhino2.pdf -L 400'
.sp 8
.PP
We can see that two of the packets, 49 and 217, are http GET requests for rhino images. Inspecting the packets further, the full request URI is 
.CW "http://www.cs.uno.edu/~gnome/<rhino image>" .
This is important as this URI corresponds to the domain mentioned in the email recovered from 
\*Q
rhino.log
\*U
meaning that there is something fishy about that website. Let's try exporting all http objects through the file toolbar and going to
.CW "export objects: http"
.sp 0.5
\X'pdf: pdfpic ./images/http_export_rhino2.pdf -C 400 175 550'
.sp 15
.PP there are some images, and somewhat look like directories or webpages. I will be exporting these into a file called 
\*Q
from_rhino2log
\*U
in the working directory.
.PP
The 
\*Q
~gnome
\*U
file gives a 404 error, while the 
\*Q
~gnome(1)
\*U
file takes us to a page that holds links to the rhino images. This indicates that the URI identified above did indeed provide the rhino images. Moving into the 
\*Q
index.html
\*U
file, we see a course syllabus.
.sp 0.5
\X'pdf: pdfpic ./images/syllabus_pic.pdf -C 400 175 550'
.sp 15
.PP
All the links contained in this webpage are of course broken, but there is some helpful information in here. The largest bit of information is the name Venkata listed in the cs.uno.edu email. This name corresponds to more files pulled from the pcap: 
\*Q
~venkata
\*U
and
\*Q
~venkata(1) .
\*U
the first of these directs to a 
\*Q
file moved
\*U
screen while the second directs to a viable webpage
.sp 0.5
\X'pdf: pdfpic ./images/venkata_html.pdf -C 400 175 550'
.sp 15
.PP
Most of these links are also broken. Once redirects to the Arsenal website, making sense of the Manchester United jabs higher up. It can be speculated that this Venkata person is in collusion with the distribution of rhino images from their site coming up with these images, and them being tied to the university identified earlier to be hosting these images.
.PP
Finally, two rhino images,
\*Q
rhino4.jpg
\*U
and
\*Q
rhino5.gif
\*U
were also recovered from the pcap with the http filter. Let's go back to the pcap and take a look at those imap packets. There is nothing of note in the IMAP packets, packets 314 - 317.
.PP
The above is all I was able to pull from 
\*Q
rhino2.log
\*U .
While I believe the connection with Venkata could be explored further, we have found some rhino images and made important links to already established evidence. Let's continue the investigation with the last log file.



.NH
Rhino3.Log
.PP
Taking the usual first step of checking the protocol hierarchy we find nothing interesting this time around, although it is good to know that there were GIFs sent, maybe there is something good in those. 
.PP
Let's do the same thing we did with 
\*Q
rhino2.log
\*U
and check the http exports.
.sp 0.5
\X'pdf: pdfpic ./images/rhino3_exported_objs.pdf -C 400 175 550'
.sp 15
.PP
Selecting save all, and using the GUI to make a new directory called
\*Q 
from_rhino3log
\*U
all the items sent over http were downloaded. Taking a look at the .gif files, there is nothing interesting. However, there are some strange named files. Let's see what they are.
.sp .2
\X'pdf: pdfpic ./images/what_in_rhino_1.pdf -L 400'
.sp 5
.PP
One of these is a webpage! But it cannot be viewed in its current form. But, using the 
.CW cp
command to copy the file into 
.CW search.html
the file can be viewed.
.sp 0.5
\X'pdf: pdfpic ./images/searchHTML.pdf -C 500 300 550'
.sp 25
.PP
This appears to be a saved search page for 
\*Q
rhino.exe
\*U
it is currently unclear what the program does. As a sidetrack I attempted to disassemble 
\*Q
rhino.exe
\*U
with Ghidra, but was unsuccessful in getting anything helpful out of it. Maybe an addendum will be written exploring this exe. As for the other files from this dump, I could not find anything of use. For now, it's time to get back to the pcap as there is more hidden!
.PP
Doing a filter for
.CW "http contains rhino"
gives mostly the information we already had. However, it is worth noting that the 
\*Q
rhino.exe
\*U
file came from the 
\*Q
~gnome
\*U
directory found in the last pcap. This links the exe file to the university website, to the rhino four and five images, and to the Venkata character.
.sp 0.5
\X'pdf: pdfpic ./images/packet110_rhino3.pdf -L 400'
.sp 10
.NH
Conclusion
.PP
There is still more to be found and inspected. However, we have answers for all the tasks set to us that are found in the section below. A future update will look further at the 
\*Q
rhino.exe
\*U
as I believe there is more hidden in there. There is also another piece of information regarding the ftp server hiding in 
\*Q
rhino.log
\*U
that I encourage you to find for yourself.


.SH
Answers
.NH 2
Who gave the telnet/ftp account
.PP
The accused telnet/ftp account was provided by Jeremy
.NH 2
what is the username and password for the account
.RS
.LP
The username is 
.B gnome
and the password is 
.B gnome123 .
.RE
.NH 2
what relevant file transfers appear in the network traces
.RS
.LP
Relevant file transfers include:
.RS

.bl
Rhino1.jpg
.bl
Rhino3.jpg
.bl
contraband.zip
.bl
Rhino4.jpg
.bl
Rhino5.gif
.bl
rhino.exe
.RE
.RE

.NH 2
what happened to the computer hard drive and where is it
.RS
.LP
The document recovered from the DD image states:
.QP
"...I zapped the hard drive and threw it into the Missippi River..."
.RE
.NH 2
what happened to the USB key
.LP
it was reformatted, possibly at RadioShack per the recovered Word document
.NH 2
what is recoverable from the DD image of the USB key
.LP
A Word document, some images, and a number of overwritten text files, along with two recipes can be recovered
.NH 2
is there any evidence connecting the USB key and network traces
.RS
.LP
\*Q
rhino2.jpg
\*U
recovered from the 
\*Q
rhino.log
\*U
pcap is the same image as 
\*Q
00106395.jpg
\*U
recovered from the usb drive.
.RE
.sp 10
.nr PS 20
.RS
.RS
.RS
.RS
.PP
Thank you for reading!
.RE
.RE
.RE
.RE
.nr PS 10
