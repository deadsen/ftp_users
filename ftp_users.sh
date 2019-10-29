#!/bin/bash -e
declare -a users
while [ true ]
do
echo -e "1 - Create user\n\
2 - Change password \n\
3 - Delete user \n\
4 - Show users \n\
0 - EXIT"
#trap "echo ' Test'" EXIT
read -p "Make your choise: " menu
#########EXIT##########
	if [ $menu -eq 0 ];then
		echo 'Bye'
		break
#######################
#
#####CREATE USER#######
	elif [ $menu -eq 1 ];then
		echo "Create user"
		read -p 'Username: ' user
		pass=$(pwgen -y 16 | awk '{print $1}')
		useradd -d /home/$user -s /sbin/nologin $user
		echo "$pass" | passwd --stdin $user
		echo -e "-----------------------------------\nYour password is:$pass\n-----------------------------------"
##########ADD QUOTA#####
		read -p "Whoud you like to add a user disk quota?(As a default there is no quota) y/n:" quota
		if [[ $quota == Y || $quota == y ]];then
			echo "yes"
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
		#read -p 'Enter Username: ' user
		n_row=$(ls /home | wc -l)
		for (( i=1; i<=n_row; i++ ))
		do
			users[$i]=$( ls /home | awk "NR==$i {print}")
			if grep -E "^${users[$i]}" '/etc/passwd' >> /dev/null;then
				echo "${users[$i]}" 
			fi
			#ls /home | awk "NR==$i {print}" > /tmp/users
			#echo "${users[$i]}"
		done
		echo "-------------------------"
		#$user
		#continue
#####################
	else
		echo "Wrong number, try again"
	fi
done
echo "$?"
echo 'END'