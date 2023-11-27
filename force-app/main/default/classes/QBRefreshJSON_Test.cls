@isTest
public class QBRefreshJSON_Test {
    @isTest
    static void testQBRefreshJSON() {
        String json = '{ "x_refresh_token_expires_in": 3600, "refresh_token": "RefreshToken123", "access_token": "AccessToken456", "expires_in": 3600, "token_type": "Bearer" }';
        QBRefreshJSON refresh = QBRefreshJSON.parse(json);
        System.assertNotEquals(null, refresh);
        System.assertNotEquals(null, refresh.refresh_token);
        }
}