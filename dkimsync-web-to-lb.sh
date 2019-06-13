#!/bin/sh

#####################################################################################################
#																			  						#
# 	Copyright (C) 1 Click Services LTD - All Rights Reserved 				  						#
# 	Unauthorized copying of this file, via any medium is strictly prohibited  						#
# 	Proprietary and confidential											  						#
#																									#
#	PROJECT:		Outbound Mail Cluster															#
# 	FILE:			dkimsync-web-to-lb.sh															#
#	DESCRIPTION:	Syncs DKIM Keys from the hosting platform to the Outbound Mail Load Balancer	#
#					ready to be synced to the individual Outbound MailWatch Hosts					#
#																									#
#	VERSION:		1.00																			#
#	AUTHOR:			Daniel McGiff <daniel.mcgiff@1clickcloud.net>									#
#	DATE:			13th June 2019																	#
#	UPDATED:		13th June 2019																	#
#																									#
#	ACKNOWLEDGEMENTS: Based on original concept by Tom Black.										#
#																									#
#																									#
#####################################################################################################

#rysnc recursive and deleting files that no longer exist. LOCAL_PATH REMOTE_USER@REMOTE_SERVER:REMOTE_PATH
#$HOSTNAME variable representing local hostname.
rsync --recursive --delete /var/cpanel/domain_keys/private/ dkimsync@outbound-mail-new.as200552.net:/var/dkim/private/$HOSTNAME