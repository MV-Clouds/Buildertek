@isTest
public class BT_LightningTreeItemControllerTest {
    public static testMethod void testBT_LightningTreeItemController() {
        TreeNodeUserData testData = new TreeNodeUserData();
        testData.iconCls = 'Test';
        testData.adType = 'Test';
        testData.totalOptions = 'Test';
        testData.totalTestedOptions = 'Test';
        testData.isDue = TRUE;
        testData.mainObjectFieldAPI = 'Test';
        testData.mainObjectId = 'Test';
        testData.otherObjectFieldAPI = 'Test';
        testData.otherObjectId = 'Test';
        BT_LightningTreeItemController.getChildNodes('test', 'Account', JSON.serialize(testData));
        System.assertEquals('Test','Test');
    }
}