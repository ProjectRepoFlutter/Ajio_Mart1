library my_project.globals;

String? userContactType = '';
String? userContactValue = '';
String userFirstName = '';
String userLastName = '';
String userFullName = userFirstName + ' ' + userLastName;

// Example of a function to clear user data (like on logout)
void clearUserData() {
  userContactType = '';
  userContactValue = '';
  userFirstName = '';
  userLastName = '';
}

// Example of a function to set user data
void setUserData(String? contactType, String? contactValue, String firstName, String lastName) {
  userContactType = contactType;
  userContactValue = contactValue;
  userFirstName = firstName;
  userLastName = lastName;
}
