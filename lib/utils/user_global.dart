library my_project.globals;

String userContactType = '';
String userContactValue = '';
String userFirstName = 'User';
String userLastName = '';
String userFullName = userFirstName + ' ' + userLastName;
String userProfilePictureUrl = '';

// Example of a function to clear user data (like on logout)
void clearUserData() {
  userContactType = '';
  userContactValue = '';
  userFirstName = '';
  userLastName = '';
  userProfilePictureUrl = '';
}

// Example of a function to set user data
void setUserData (String contactType, String contactValue, String firstName, String lastName) {
  userContactType = contactType;
  userContactValue = contactValue;
  userFirstName = firstName;
  userLastName = lastName;
}
