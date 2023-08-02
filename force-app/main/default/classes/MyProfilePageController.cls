/**
 * An apex class that updates portal user details.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private boolean isEdit = false;

    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        if(Schema.sObjectType.User.fields.Id.isAccessible()&&
          Schema.sObjectType.User.fields.email.isAccessible() &&
          Schema.sObjectType.User.fields.username.isAccessible() &&
          Schema.sObjectType.User.fields.communitynickname.isAccessible() &&
          Schema.sObjectType.User.fields.timezonesidkey.isAccessible() &&
          Schema.sObjectType.User.fields.languagelocalekey.isAccessible() &&
          Schema.sObjectType.User.fields.firstname.isAccessible() &&
          Schema.sObjectType.User.fields.lastname.isAccessible() &&
          Schema.sObjectType.User.fields.phone.isAccessible() &&
          Schema.sObjectType.User.fields.title.isAccessible() &&
          Schema.sObjectType.User.fields.street.isAccessible() &&
          Schema.sObjectType.User.fields.city.isAccessible() &&
		  Schema.sObjectType.User.fields.country.isAccessible() &&
          Schema.sObjectType.User.fields.postalcode.isAccessible() &&
          Schema.sObjectType.User.fields.state.isAccessible() &&
          Schema.sObjectType.User.fields.localesidkey.isAccessible() &&
          Schema.sObjectType.User.fields.mobilephone.isAccessible() &&
          Schema.sObjectType.User.fields.extension.isAccessible() &&
          Schema.sObjectType.User.fields.fax.isAccessible() &&
          Schema.sObjectType.User.fields.usertype.isAccessible() &&
          Schema.sObjectType.Contact.fields.email.isAccessible()){
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
          }
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }

    public Boolean getIsEdit() {
        return isEdit;
    }

    public void edit() {
        isEdit=true;
    }

    public void save() {
        try {
            if(Schema.sObjectType.User.fields.usertype.isUpdateable()){
            update user;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public void cancel() {
        isEdit=false;
        if(Schema.sObjectType.User.fields.Id.isAccessible()&&
          Schema.sObjectType.User.fields.email.isAccessible() &&
          Schema.sObjectType.User.fields.username.isAccessible() &&
          Schema.sObjectType.User.fields.communitynickname.isAccessible() &&
          Schema.sObjectType.User.fields.timezonesidkey.isAccessible() &&
          Schema.sObjectType.User.fields.languagelocalekey.isAccessible() &&
          Schema.sObjectType.User.fields.firstname.isAccessible() &&
          Schema.sObjectType.User.fields.lastname.isAccessible() &&
          Schema.sObjectType.User.fields.phone.isAccessible() &&
          Schema.sObjectType.User.fields.title.isAccessible() &&
          Schema.sObjectType.User.fields.street.isAccessible() &&
          Schema.sObjectType.User.fields.city.isAccessible() &&
		  Schema.sObjectType.User.fields.country.isAccessible() &&
          Schema.sObjectType.User.fields.postalcode.isAccessible() &&
          Schema.sObjectType.User.fields.state.isAccessible() &&
          Schema.sObjectType.User.fields.localesidkey.isAccessible() &&
          Schema.sObjectType.User.fields.mobilephone.isAccessible() &&
          Schema.sObjectType.User.fields.extension.isAccessible() &&
          Schema.sObjectType.User.fields.fax.isAccessible() &&
          Schema.sObjectType.Contact.fields.email.isAccessible()){
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
          }
    }    
}