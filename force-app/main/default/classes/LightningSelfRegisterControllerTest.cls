@isTest
public class LightningSelfRegisterControllerTest {

    @isTest
    public static void test(){
        
        Account testAccount = new Account(Name = 'Test Account3461897');
        insert testAccount;
        string response = LightningSelfRegisterController.selfRegister('TestFirst','TestLast','test@test3227547.com','testpassword', 'testpassword',testAccount.Id, 'www.324regconfirmURL.com','FirstName;LastName;','www.324startURL.com',true);
    }
}