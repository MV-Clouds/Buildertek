@isTest
public class LightningLoginFormControllerTest {
    
    @isTest
    public static void test(){
        
        LightningLoginFormController lightingController = new LightningLoginFormController();
        
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        // registerUser always returns null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);
        
        LightningLoginFormController.getIsUsernamePasswordEnabled();
        LightningLoginFormController.getIsSelfRegistrationEnabled();
       	LightningLoginFormController.getSelfRegistrationUrl();
        LightningLoginFormController.getForgotPasswordUrl();
        string response = LightningLoginFormController.login('test User', 'test@force.com', 'www.test3274984.com');
        
    }

}