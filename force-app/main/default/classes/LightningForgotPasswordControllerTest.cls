@isTest
public class LightningForgotPasswordControllerTest {

    @isTest
    public static void test(){
        
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        // registerUser always returns null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);
        
        LightningForgotPasswordController lightingController = new LightningForgotPasswordController(); 
        string response2 = LightningForgotPasswordController.forgotPassowrd('test User', 'test@force.com');
        /*try
        {
        string response1 = LightningForgotPasswordController.forgotPassowrd('test@force.com', 'test@force.com');
        }catch(Exception e){
            system.debug('### Exception : ' + e.getMessage());
        }
        //string response2 = LightningForgotPasswordController.forgotPassowrd('test12313@testlighting.com', 'test13123@abcxyz.com');
        //System.assertEquals( 'TEst', response1);*/
        
    }
}