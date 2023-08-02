/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlOrderByTest
* Created by Sagar
*
* Test class for BT_SoqlOrderBy

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlOrderByTest {

    private static testmethod void testNullFieldName(){
        assertExceptionThrown(null);
        system.assertEquals('test', 'test');
    }

    private static testmethod void testBlankFieldName(){
        assertExceptionThrown(' ');
        system.assertEquals('test', 'test');
    }

    private static void assertExceptionThrown(final String name){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlOrderBy(name);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testNameOnly(){
        final BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name');
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name',orderBy.toSoql());
    }

    private static testmethod void testAscendingNullsLast(){
        BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').ascending().nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS LAST',orderBy.toSoql());

        orderBy = new BT_SoqlOrderBy('name').nullsLast().ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS LAST',orderBy.toSoql());
    }

    private static testmethod void testDescendingNullsFirst(){
        BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').descending().nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS FIRST',orderBy.toSoql());

        orderBy = new BT_SoqlOrderBy('name').nullsFirst().descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testAscendingNullsFirst(){
        BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').ascending().nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS FIRST',orderBy.toSoql());

        orderBy = new BT_SoqlOrderBy('name').nullsFirst().ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testDescendingNullsLast(){
        BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').descending().nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS LAST',orderBy.toSoql());

        orderBy = new BT_SoqlOrderBy('name').nullsLast().descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS LAST',orderBy.toSoql());
    }


    private static testmethod void testAscending(){
        BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC',orderBy.toSoql());
    }

    private static testmethod void testDescending(){
        final BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC',orderBy.toSoql());
    }

    private static testmethod void testNullsFirst(){
        final BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testNullsLast(){
        final BT_SoqlOrderBy orderBy = new BT_SoqlOrderBy('name').nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name NULLS LAST',orderBy.toSoql());
    }
}