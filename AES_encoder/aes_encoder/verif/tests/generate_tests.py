import os
import time

# To generate tests
# Can be modify by user
file_test       = "ECBVarKey256.rsp"
file_test_rqst  = "aes_cipher_rqst.txt"
file_test_rtn   = "aes_cipher_rtn.txt"
pathsrc         = "test_ECB"
pathdest        = "test_cipher_256_ECB"

# Can't be modify by user
pathsrcfile_test = pathsrc + '/' + file_test
pathdestfile_test_rqst = pathdest + '/' + file_test_rqst
pathdestfile_test_rtn = pathdest + '/' + file_test_rtn


# To create directories (if necessary)
if not os.path.exists(pathdest):
    os.mkdir(pathdest)

if os.path.exists(pathsrcfile_test) & os.path.exists(pathdest):
    # Recover data from file_test
    with open(str(pathsrcfile_test), "r") as file :
        lines = file.readlines()
        nb_lines = len(lines)
        nb_data = (nb_lines - 10)/10 # 100

        # Recover Keys
        kstart = 10 # k start
        k = kstart
        key_lines = [''] * nb_data
        i=0
        while i< nb_data:
            key_lines[i] = lines[k].upper()
            k = k + 5
            i = i + 1

        # Recover Plaintexts
        plaintext_lines = [''] * nb_data
        p = kstart + 1 # p start
        i = 0
        while i < nb_data:
            plaintext_lines[i] = lines[p].upper()
            p = p + 5
            i = i + 1

        # Recover Ciphertexts
        ciphertext_lines = [''] * nb_data
        c = kstart + 2 # c start
        i = 0
        while i < nb_data:
            ciphertext_lines[i] = lines[c].upper()
            c = c + 5
            i = i + 1
        file.close()

    # To generate the requested file (txt)
    with open(str(pathdestfile_test_rqst), "w") as file :
        nb_tests = nb_data
        i=0
        while i<nb_tests:
            file.write(plaintext_lines[i][12:44] + ' ' + key_lines[i][6:70] + '\n')
            i=i+1
        file.close()

    # To generate the returned file (txt)
    with open(str(pathdestfile_test_rtn), "w") as file :
        nb_tests = nb_data
        i=0
        while i<nb_tests:
            file.write(ciphertext_lines[i][13:45] + '\n')
            i=i+1
        file.close()

    print("Files are correctly created.")

else:
    print("Info error : The directory '" + pathsrcfile_test +
          "' does not exist.\nCreate this directory and place your 'file_test' inside.")


