/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlOptionsTest
* Created by Sagar
*
* Test class for BT_SoqlOptions

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlOptionsTest {

    private static testmethod void testDefault(){
        System.assertEquals(true,BT_SoqlOptions.DEFAULT_OPTIONS.escapeSingleQuotes);
        System.assertEquals(false,BT_SoqlOptions.DEFAULT_OPTIONS.wildcardStringsInLikeOperators);
    }

    private static testmethod void test_escapeSingleQuotes(){
        final BT_SoqlOptions options = new BT_SoqlOptions();
        System.assertEquals(true,options.escapeSingleQuotes);
        System.assertEquals(options,options.doNotEscapeSingleQuotes());
        System.assertEquals(false,options.escapeSingleQuotes);
        System.assertEquals(options,options.escapeSingleQuotes());
        System.assertEquals(true,options.escapeSingleQuotes);
    }

    private static testmethod void test_wildcardStringsInLikeOperators(){
        final BT_SoqlOptions options = new BT_SoqlOptions();
        System.assertEquals(false,options.wildcardStringsInLikeOperators);
        System.assertEquals(options,options.wildcardStringsInLikeOperators());
        System.assertEquals(true,options.wildcardStringsInLikeOperators);
        System.assertEquals(options,options.doNotWildcardStringsInLikeOperators());
        System.assertEquals(false,options.wildcardStringsInLikeOperators);
    }


}