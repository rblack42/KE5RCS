Gateway Software Install Script
###############################

..  include:: /references.inc

The script provided with the Icom_ software is a huge file with over 100 steps.
The script is fairly easy to run, but it has features that are a bit
old-fashioned in today's world. To make sure I understood what was happening as
this script runs, I decided to break it up and look at each of the steps. This
note is the result of that study.

..  note:: 

    This script needs to be run while logged in as the `root` user. 

    ..  code-block:: bash

        $ ssh <server-ip-address>
        $ sudo su -
        <enter sudo user password>
        # cd /home/n5ujh/dstar/RS-RP2C
        ./dstar_gw-install

Script Structure
****************

The script is set up as three major function, and a main routine that files up
things as needed. 

The main routine is found at the end of the script (at line 1585. The first
thing it does is run the ``check`` function, which examines the running system
to see if installation can proceed.

..  literalinclude::   files/dstar_gw-install
    :lines: 1584-1593
    :lineno-start: 1584

Following this check, the script looks for options that control what happens.
You can either ``install`` or ``uninstall`` the Icom_ |DS| software using this
script. By default, it runs ``install``

..  literalinclude::   files/dstar_gw-install
    :lines: 1596-1654
    :lineno-start: 1596

..  note::

    The Gateway configuration file mentioned here is located at
    ``/opt/products/dstar/dstar_gw/dsgwd/dsgwd.conf``. Details on that file are
    included elsewhere.

Notice that if the install fails, the script will let you try to ``uninstall``
whatever managed to get installed.
   
Finally, temporary files created by the install procedure are removed.

..  literalinclude::   files/dstar_gw-install
    :lines: 1657-1688
    :lineno-start: 1657

Check Function
**************

The ``check`` function examines the system to see if |DS| processes are
running, and if files are already in place. 

The first thing the script does is make sure you are running as the ``root``
user:

..  literalinclude::   files/dstar_gw-install
    :lines: 1350-1361
    :lineno-start: 1350

Next, we look for temporary files, and delete them if found:

..  literalinclude::   files/dstar_gw-install
    :lines: 1370-1381
    :lineno-start: 1370

Unpack ``dsinst`` files
=======================

We will copy a ``tar`` file containing a number of files that need to be
installed into a temporary directory and unpack them:

..  literalinclude::   files/dstar_gw-install
    :lines: 1383-1413
    :lineno-start: 1413

In the next section, we verify that needed files are ready to be copied from
the temporary directory:

..  literalinclude::   files/dstar_gw-install
    :lines: 1415-1470
    :lineno-start: 1415

Check the ``gcc`` is installed
==============================

The installation will need to compile a few things, so this check makes sure
the build tools were installed:

..  literalinclude::   files/dstar_gw-install
    :lines: 1472-1483
    :lineno-start: 1472

Verify that ``named`` is installed:
===================================

The gateway server will run a local DNS server. This tool will manage assigned
IP addresses for all |DS| users. 

..  literalinclude::   files/dstar_gw-install
    :lines: 1485-1491
    :lineno-start: 1485

Check for running D-Star Processes
==================================

The script checks to see if a number of |DS| processes are running. You will be
asked if you want to stop each of these if they are running:

    * ``dsipsvd`` - ???

    * ``dsgwd`` - primary |DS| application

    * ``httpd`` - Apache web server

    * ``postgres`` - |DS| database server

    * ``tomcat`` - Java Application server


..  literalinclude::   files/dstar_gw-install
    :lines: 1493-1581
    :lineno-start: 1493

This completes the ``check`` function. If this routine returns with no errors,
it is safe to install the |DS| software.


Install Function
****************

The installation procedure has a large number of steps. The script tries to log
things and back out of errors. The actual work in this script is small compared
to all this error checking. (A modern tool like Ansible would clean this up
immensely!)


Initialization
==============


The script begins by check ing to see if the ``/opt/products/`` directory
already exists.  This is the directory where all Icom_ |DS| software is
installed. If that directory exists, the user is asked if they want to
reinstall to software. Answering "yes" will result in the old directory being
renamed with the current date, and the script will proceed to install
everything again.

..  literalinclude::   files/dstar_gw-install
    :lines: 1-31
    :lineno-start: 1

Next, we make sure the current directory is the one containing the install
script:

..  literalinclude::   files/dstar_gw-install
    :lines: 33-39
    :lineno-start: 33

Create ``dstar`` Group and User
*******************************

In the next segment, the ``dstar`` group is added. Note that everything done by
this scrit gets logged in ``dstar_gw-install.log`` in the `root` home
directory. 

You can check that this step worked by examining the ``/etc/group`` file:

..  code-block:: bash

    $ more /etc/group | grep dstar
    dstar:x:501:

The ``dstar`` user is created in a similar way:

..  literalinclude::   files/dstar_gw-install
    :lines: 53-118
    :lineno-start: 53

The check that this succeeded is this:

..  code-block:: bash

    $ more /etc/passwd | grep dstar
    dstar:x:501:501::/home/dstar:/bin/bash

This shows the new users home directory and default shell are set. The password
has been set using a hash provided with the script. This is how the Trust
Server administrators are able to log into the gateway server when needed.
(Note: I removed the hash in this note, and replaced it with a template variable.)

..  literalinclude::   files/dstar_gw-install
    :lines: 120-129
    :lineno-start: 120

Install Postgress
*****************

The Postgress database is used to manage local |DS| user registration data. SInce most gateways only manage a liited number of users, this seems like a heavyweight solution to manaing this data, but that is what Icom_ went with!

The first segment creates a ``postgress`` group:

..  literalinclude::   files/dstar_gw-install
    :lines: 131-195
    :lineno-start: 131

Again, we can check that this worked by doing this:

..  code-block:: bash

    $ more /etc/group | grep postgres
    postgres:x:502:

Next, the `postgres` user is created. This script segment is identical to the one used to greate the `dstar` user. Again, the default password has been removed. 

..  literalinclude::   files/dstar_gw-install
    :lines: 197-212
    :lineno-start: 197

Configuring the ``dstar`` Account
*********************************

The `dstar` user account is tuned up a bit for Trust System administrator
access. Before this is done, a temporary backup directory, ``/tmp/ds_inst`` is
created to save files being replaced, in case the script fails. If it does
fail, an attempt is made to restore things to the original configuration.

This first segment backs up the current ``.bashrc`` file:


..  literalinclude::   files/dstar_gw-install
    :lines: 214-226
    :lineno-start: 214

Next, the new file is copied from the Icom_ |DS| files.

..  literalinclude::   files/dstar_gw-install
    :lines: 228-240
    :lineno-start: 228

Configure the ``postgres`` account
**********************************

We do the same thing for the ``postgres`` user account:

..  literalinclude::   files/dstar_gw-install
    :lines: 242-249
    :lineno-start: 242

..  literalinclude::   files/dstar_gw-install
    :lines: 251-258
    :lineno-start: 251

..  literalinclude::   files/dstar_gw-install
    :lines: 260-267
    :lineno-start: 260

..  literalinclude::   files/dstar_gw-install
    :lines: 269-276
    :lineno-start: 269

..  literalinclude::   files/dstar_gw-install
    :lines: 278-285
    :lineno-start: 278

..  literalinclude::   files/dstar_gw-install
    :lines: 287-294
    :lineno-start: 287

..  literalinclude::   files/dstar_gw-install
    :lines: 296-303
    :lineno-start: 296

..  literalinclude::   files/dstar_gw-install
    :lines: 305-312
    :lineno-start: 305

..  literalinclude::   files/dstar_gw-install
    :lines: 314-321
    :lineno-start: 314

..  literalinclude::   files/dstar_gw-install
    :lines: 323-339
    :lineno-start: 323

..  literalinclude::   files/dstar_gw-install
    :lines: 341-348
    :lineno-start: 341

..  literalinclude::   files/dstar_gw-install
    :lines: 350-357
    :lineno-start: 350

..  literalinclude::   files/dstar_gw-install
    :lines: 359-366
    :lineno-start: 359

..  literalinclude::   files/dstar_gw-install
    :lines: 368-375
    :lineno-start: 368

..  literalinclude::   files/dstar_gw-install
    :lines: 377-384
    :lineno-start: 377

..  literalinclude::   files/dstar_gw-install
    :lines: 386-393
    :lineno-start: 386

..  literalinclude::   files/dstar_gw-install
    :lines: 395-402
    :lineno-start: 395

..  literalinclude::   files/dstar_gw-install
    :lines: 404-411
    :lineno-start: 404

..  literalinclude::   files/dstar_gw-install
    :lines: 413-414
    :lineno-start: 413

..  literalinclude::   files/dstar_gw-install
    :lines: 415-423
    :lineno-start: 415

..  literalinclude::   files/dstar_gw-install
    :lines: 425-432
    :lineno-start: 425

..  literalinclude::   files/dstar_gw-install
    :lines: 433-441
    :lineno-start: 433

..  literalinclude::   files/dstar_gw-install
    :lines: 443-450
    :lineno-start: 443

..  literalinclude::   files/dstar_gw-install
    :lines: 452-459
    :lineno-start: 452

..  literalinclude::   files/dstar_gw-install
    :lines: 461-468
    :lineno-start: 461

..  literalinclude::   files/dstar_gw-install
    :lines: 470-477
    :lineno-start: 470

..  literalinclude::   files/dstar_gw-install
    :lines: 479-486
    :lineno-start: 479

..  literalinclude::   files/dstar_gw-install
    :lines: 488-495
    :lineno-start: 488

..  literalinclude::   files/dstar_gw-install
    :lines: 497-504
    :lineno-start: 497

..  literalinclude::   files/dstar_gw-install
    :lines: 506-513
    :lineno-start: 506

..  literalinclude::   files/dstar_gw-install
    :lines: 515-522
    :lineno-start: 515

..  literalinclude::   files/dstar_gw-install
    :lines: 524-531
    :lineno-start: 524

..  literalinclude::   files/dstar_gw-install
    :lines: 533-540
    :lineno-start: 533

..  literalinclude::   files/dstar_gw-install
    :lines: 542-549
    :lineno-start: 542

..  literalinclude::   files/dstar_gw-install
    :lines: 551-558
    :lineno-start: 551

..  literalinclude::   files/dstar_gw-install
    :lines: 560-567
    :lineno-start: 560

..  literalinclude::   files/dstar_gw-install
    :lines: 569-576
    :lineno-start: 569

..  literalinclude::   files/dstar_gw-install
    :lines: 578-585
    :lineno-start: 578

..  literalinclude::   files/dstar_gw-install
    :lines: 587-594
    :lineno-start: 587

..  literalinclude::   files/dstar_gw-install
    :lines: 596-603
    :lineno-start: 596

..  literalinclude::   files/dstar_gw-install
    :lines: 605-612
    :lineno-start: 605

..  literalinclude::   files/dstar_gw-install
    :lines: 614-621
    :lineno-start: 614

..  literalinclude::   files/dstar_gw-install
    :lines: 623-630
    :lineno-start: 623

..  literalinclude::   files/dstar_gw-install
    :lines: 631-639
    :lineno-start: 631

..  literalinclude::   files/dstar_gw-install
    :lines: 641-648
    :lineno-start: 641

..  literalinclude::   files/dstar_gw-install
    :lines: 650-661
    :lineno-start: 650

..  literalinclude::   files/dstar_gw-install
    :lines: 663-668
    :lineno-start: 663

..  literalinclude::   files/dstar_gw-install
    :lines: 670-680
    :lineno-start: 670

..  literalinclude::   files/dstar_gw-install
    :lines: 682-692
    :lineno-start: 682

..  literalinclude::   files/dstar_gw-install
    :lines: 694-704
    :lineno-start: 694

..  literalinclude::   files/dstar_gw-install
    :lines: 706-716
    :lineno-start: 706

..  literalinclude::   files/dstar_gw-install
    :lines: 718-728
    :lineno-start: 718

..  literalinclude::   files/dstar_gw-install
    :lines: 730-740
    :lineno-start: 730

..  literalinclude::   files/dstar_gw-install
    :lines: 742-752
    :lineno-start: 742

..  literalinclude::   files/dstar_gw-install
    :lines: 754-764
    :lineno-start: 754

..  literalinclude::   files/dstar_gw-install
    :lines: 766-776
    :lineno-start: 766

..  literalinclude::   files/dstar_gw-install
    :lines: 778-785
    :lineno-start: 778

..  literalinclude::   files/dstar_gw-install
    :lines: 787-794
    :lineno-start: 787

..  literalinclude::   files/dstar_gw-install
    :lines: 796-803
    :lineno-start: 796

..  literalinclude::   files/dstar_gw-install
    :lines: 805-815
    :lineno-start: 805

..  literalinclude::   files/dstar_gw-install
    :lines: 817-827
    :lineno-start: 817

..  literalinclude::   files/dstar_gw-install
    :lines: 829-836
    :lineno-start: 829

..  literalinclude::   files/dstar_gw-install
    :lines: 838-845
    :lineno-start: 838

..  literalinclude::   files/dstar_gw-install
    :lines: 847-857
    :lineno-start: 847

..  literalinclude::   files/dstar_gw-install
    :lines: 859-869
    :lineno-start: 859

..  literalinclude::   files/dstar_gw-install
    :lines: 871-879
    :lineno-start: 871

..  literalinclude::   files/dstar_gw-install
    :lines: 881-888
    :lineno-start: 881

..  literalinclude::   files/dstar_gw-install
    :lines: 890-897
    :lineno-start: 890

..  literalinclude::   files/dstar_gw-install
    :lines: 899-906
    :lineno-start: 899

..  literalinclude::   files/dstar_gw-install
    :lines: 908-915
    :lineno-start: 908

..  literalinclude::   files/dstar_gw-install
    :lines: 917-924
    :lineno-start: 917

..  literalinclude::   files/dstar_gw-install
    :lines: 926-933
    :lineno-start: 926

..  literalinclude::   files/dstar_gw-install
    :lines: 935-942
    :lineno-start: 935

..  literalinclude::   files/dstar_gw-install
    :lines: 944-951
    :lineno-start: 944

..  literalinclude::   files/dstar_gw-install
    :lines: 953-960
    :lineno-start: 953

..  literalinclude::   files/dstar_gw-install
    :lines: 962-969
    :lineno-start: 962

..  literalinclude::   files/dstar_gw-install
    :lines: 971-978
    :lineno-start: 971

..  literalinclude::   files/dstar_gw-install
    :lines: 980-987
    :lineno-start: 980

..  literalinclude::   files/dstar_gw-install
    :lines: 989-996
    :lineno-start: 989

..  literalinclude::   files/dstar_gw-install
    :lines: 998-1005
    :lineno-start: 998

..  literalinclude::   files/dstar_gw-install
    :lines: 1007-1014
    :lineno-start: 1007

..  literalinclude::   files/dstar_gw-install
    :lines: 1016-1023
    :lineno-start: 1016

..  literalinclude::   files/dstar_gw-install
    :lines: 1025-1032
    :lineno-start: 1025

..  literalinclude::   files/dstar_gw-install
    :lines: 1035-1042
    :lineno-start: 1035

..  literalinclude::   files/dstar_gw-install
    :lines: 1044-1051
    :lineno-start: 1044

..  literalinclude::   files/dstar_gw-install
    :lines: 1053-1060
    :lineno-start: 1053

..  literalinclude::   files/dstar_gw-install
    :lines: 1062-1069
    :lineno-start: 1062

..  literalinclude::   files/dstar_gw-install
    :lines: 1071-1078
    :lineno-start: 1071

..  literalinclude::   files/dstar_gw-install
    :lines: 1080-1087
    :lineno-start: 1080

..  literalinclude::   files/dstar_gw-install
    :lines: 1089-1098
    :lineno-start: 1089

..  literalinclude::   files/dstar_gw-install
    :lines: 1100-1107
    :lineno-start: 1100

..  literalinclude::   files/dstar_gw-install
    :lines: 1109-1116
    :lineno-start: 1109

..  literalinclude::   files/dstar_gw-install
    :lines: 1118-1130
    :lineno-start: 1118

..  literalinclude::   files/dstar_gw-install
    :lines: 1132-1150
    :lineno-start: 1132

..  literalinclude::   files/dstar_gw-install
    :lines: 1152-1159
    :lineno-start: 1159

..  literalinclude::   files/dstar_gw-install
    :lines: 1161-1168
    :lineno-start: 1161

..  literalinclude::   files/dstar_gw-install
    :lines: 1170-1182
    :lineno-start: 1170

..  literalinclude::   files/dstar_gw-install
    :lines: 1184-1230
    :lineno-start: 1184

..  literalinclude::   files/dstar_gw-install
    :lines: 1241-1259
    :lineno-start: 1241

..  literalinclude::   files/dstar_gw-install
    :lines: 1261-1279
    :lineno-start: 1261

..  literalinclude::   files/dstar_gw-install
    :lines: 1281-1299
    :lineno-start: 1281

..  literalinclude::   files/dstar_gw-install
    :lines: 1301-1311
    :lineno-start: 1301

..  literalinclude::   files/dstar_gw-install
    :lines: 1313-1323
    :lineno-start: 1313

..  literalinclude::   files/dstar_gw-install
    :lines: 1325-1347
    :lineno-start: 1325

..  literalinclude::   files/dstar_gw-install
    :lines: 1350-1353
    :lineno-start: 1350

..  literalinclude::   files/dstar_gw-install
    :lines: 1355-1361
    :lineno-start: 1355

..  literalinclude::   files/dstar_gw-install
    :lines: 1363-1368
    :lineno-start: 1363

..  literalinclude::   files/dstar_gw-install
    :lines: 1370-1381
    :lineno-start: 1370

..  literalinclude::   files/dstar_gw-install
    :lines: 1383-1389
    :lineno-start: 1383

..  literalinclude::   files/dstar_gw-install
    :lines: 1391-1397
    :lineno-start: 1391

..  literalinclude::   files/dstar_gw-install
    :lines: 1399-1405
    :lineno-start: 1399

..  literalinclude::   files/dstar_gw-install
    :lines: 1407-1413
    :lineno-start: 1407

..  literalinclude::   files/dstar_gw-install
    :lines: 1415-1422
    :lineno-start: 1415

..  literalinclude::   files/dstar_gw-install
    :lines: 1424-1430
    :lineno-start: 1424

..  literalinclude::   files/dstar_gw-install
    :lines: 1432-1438
    :lineno-start: 1432

..  literalinclude::   files/dstar_gw-install
    :lines: 1440-1446
    :lineno-start: 1440

..  literalinclude::   files/dstar_gw-install
    :lines: 1448-1452
    :lineno-start: 1448

..  literalinclude::   files/dstar_gw-install
    :lines: 1454-1458
    :lineno-start: 1454

..  literalinclude::   files/dstar_gw-install
    :lines: 1460-1464
    :lineno-start: 1460

..  literalinclude::   files/dstar_gw-install
    :lines: 1466-1470
    :lineno-start: 1466

..  literalinclude::   files/dstar_gw-install
    :lines: 1472-1477
    :lineno-start: 1472

..  literalinclude::   files/dstar_gw-install
    :lines: 1479-1483
    :lineno-start: 1479

..  literalinclude::   files/dstar_gw-install
    :lines: 1485-1491
    :lineno-start: 1485

..  literalinclude::   files/dstar_gw-install
    :lines: 1493-1509
    :lineno-start: 1493

..  literalinclude::   files/dstar_gw-install
    :lines: 1511-1526
    :lineno-start: 1511

..  literalinclude::   files/dstar_gw-install
    :lines: 1528-1543
    :lineno-start: 1528

..  literalinclude::   files/dstar_gw-install
    :lines: 1546-1561
    :lineno-start: 1546

..  literalinclude::   files/dstar_gw-install
    :lines: 1563-1583
    :lineno-start: 1563

..  literalinclude::   files/dstar_gw-install
    :lines: 1585-1594
    :lineno-start: 1585

..  literalinclude::   files/dstar_gw-install
    :lines: 1597-1654
    :lineno-start: 1597

..  literalinclude::   files/dstar_gw-install
    :lines: 1657-1668
    :lineno-start: 1657

..  vim:filetype=rst spell:
