/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_ApplicationExceptionTest
* Created by Sagar
*
* - Test class for BT_ApplicationException

* - Modifications:
* - Sagar– Initial Development
************************************************************************** */
@isTest
private class BT_ApplicationExceptionTest {

    static testMethod void exceptionTest() {
        String message = 'This is a test';
        try {
            throw new BT_ApplicationException(message);
        } catch (BT_ApplicationException ex){
            System.assertEquals(message, ex.getMessage());
        }
    }
}