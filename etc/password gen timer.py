import random
import string
import time
password_count = 0  # Initialize the password count
start_time = time.time()  # Record the start time
textFile = open("rockyou.txt", "a")
NumOfPasswords = int(float(input("How many passwords do you want to generate? ")))
PasswordLength = int(float(input("How long do you want the passwords to be? ")))
end_time = time.time()  # Record the end time
elapsed_time = end_time - start_time  # Calculate the elapsed time
try:
    
    for i in range(NumOfPasswords):  # Set the number of passwords to generate
        # Set the desired password length
        password_length = PasswordLength 

        characters = string.ascii_letters + string.digits + string.punctuation

        # Using a list to accumulate characters
        password_list = []   

        for _ in range(password_length):
            password_list.append(random.choice(characters))

        # Join the characters to form the password string
        password = ''.join(password_list)

        print(f"{password}", file=textFile)
        print(f"{password}")  # Print the generated password to the console
        password_count += 1  # Increment the password count
except KeyboardInterrupt:
    
    print(f"\nGenerated and printed {password_count:,} passwords.")
    print(f"Elapsed time: {elapsed_time:.2f} seconds.")

print(f"\nGenerated and printed {password_count:,} passwords.")
print(f"Elapsed time: {elapsed_time:.2f} seconds.")
exit()
