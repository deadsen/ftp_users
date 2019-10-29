#!/bin/bash -e
declare -a users
re='^[0-9]+$'
while [ true ]
do
echo -e "1 - Create user\n\
2 - Change password \n\
3 - Delete user \n\
4 - Show users \n\
5 - Edit disk quotas\n\
0 - Exit"
#trap "echo ' Test'" EXIT
read -p "Make your choise: " menu
#########CHECK INPUT VALUES#########
	if ! [[ $menu =~ $re ]];then
		echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nerror: You can only enter number values\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		continue
######################
#
#########EXIT##########
	elif [ $menu -eq 0 ];then
		echo 'Bye'
		break
######################
#
#####CREATE USER#######
	elif [ $menu -eq 1 ];then
		echo "Create user"
		read -p 'Username: ' user
		if ! [ -z $user ];then
			pass=$(pwgen -y 16 | awk '{print $1}')
			useradd -d /var/ftp/$user -s /sbin/nologin $user
			echo "$pass" | passwd --stdin $user
			#echo -e "-----------------------------------\nYour password is:$pass\n-----------------------------------"
##########ADD QUOTA#####
			read -p "Whoud you like to add a user disk quota?(As a default there is no quota) y/n:" varquota
			if [[ $varquota == Y || $varquota == y ]];then
				#echo "yes"#add quota code should be there
				read -p 'Please enter number of gigabytes for userquota : ' quota
				setquota $user $quota'G' $quota'G' 0 0 /var/ftp
				echo -e "-----------------------------------\nYour password is:$pass\n-----------------------------------"
				#echo "$(repquota -a | grep $user)"
			else
				echo "Warning!!! There is no quota as a default"
				echo -e "-----------------------------------\nYour password is:$pass\n-----------------------------------"
			fi
		else
			echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nUsername can not be empty\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		fi
########################
#
#####CHANGE PASSWORD####
	elif [ $menu -eq 2 ];then 
		echo "Changing password"
		read -p 'Enter Username: ' user
		if grep -w "$user" '/etc/passwd' >> /dev/null;then
			pass=$(pwgen -y 16 | awk '{print $1}')
			echo "$pass" | passwd --stdin $user
			echo -e "-----------------------------------\nYour password is:$pass\n-----------------------------------"
		else
			    echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nUser $user does not exist\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		fi
		#continue
#######################
#
#####DELETE_USER#######
	elif [ $menu -eq 3 ];then
		echo "Deleting user"
		read -p 'Enter Username: ' user
		if grep -w "$user" '/etc/passwd' >> /dev/null;then
			read -p 'Would you like, to delete the home directory y/n (NO is default): ' path
			read -p "Are you really would like to delete $user y/n: " del
			while [ true ]
			do
				if [[ $del == Y || $del == y ]];then
					echo "yes"
					if [[ $path == Y || $path == y ]];then
						userdel -r $user
					else
						userdel $user
					fi
					echo -e "-------------------------\nUser $user was deleted\n------------------------"
				break
				elif [[ $del == N || $del == n ]];then
				echo "no"
				break
				else
				read -p "Please enter y/n:" del
				fi
			done
		else
		echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nUser $user does not exist\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		fi
		#continue
######################
#
#####LIST USERS#######
	elif [ $menu -eq 4 ];then
		echo -e "-------------------------\nList of users\n-------------------------"
		n_row=$(ls /home | wc -l)
		for (( i=1; i<=n_row; i++ ))
		do
			users[$i]=$( ls /home | awk "NR==$i {print}")
			if grep -E "^${users[$i]}" '/etc/passwd' >> /dev/null;then
				echo "${users[$i]}" 
			fi
		done
		echo "-------------------------"
#####################
######SHOW AND EDIT QUOTAS####
	elif [ $menu -eq 5 ];then
		while [ true ]
		do
			echo -e "1 - Show quotas\n2 - Update quota\n0 - Exit"
			read -p 'Make your choise : ' check
			if ! [[ $check =~ $re ]];then
			echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nerror: You can only enter number values\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			continue
			elif [ $check -eq 1 ];then
				repquota -a
			elif [ $check -eq 2 ];then
				read -p 'Username : ' user
				read -p 'Please enter number gigabytes for userquota (Numbers only) : ' quota
				if [[ $quota =~ $re ]];then
					setquota $user $quota'G' $quota'G' 0 0 /var/ftp
					echo -e '-----------------------------------\nQuota successfully updated\n-----------------------------------'
					echo '----------------------------------------------------------------------'
					repquota -a | grep $user
					echo '----------------------------------------------------------------------'
				else
					echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nError: You can only enter number values\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
				fi
			elif [ $check -eq 0 ];then
			break
			else
				echo 'Wrong number, try again'
			fi
		done
####################
	else
		echo "Wrong number, try again"
	fi
done