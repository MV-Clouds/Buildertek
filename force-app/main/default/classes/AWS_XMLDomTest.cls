/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: AWS_XMLDomTest
* Created by Sagar: 06/05/2017
* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class AWS_XMLDomTest {
    public static testmethod void testGeneral() { 
        AWS_XMLDom d = new AWS_XMLDom('<book  author="Manoj" >My Book</book>');       
        AWS_XMLDom.Element e = d.getElementsByTagName('book')[0];
        system.assert(e.getAttribute('author') =='Manoj' ); 
        
        d = new AWS_XMLDom(); 
        d.parseFromString('<book  author="Manoj" >My Book</book>');
         
        d = new AWS_XMLDom('<books><book>My Book</book></books>');
        system.assert (d.getElementsByTagName('book')[0].nodeValue == 'My Book' );
        
        d = new AWS_XMLDom('<books><book author="Manoj" date="1999" >My Book</book><book author="Ron" >Your Book</book></books>'); 
    }
    
    public static testmethod void testListBucketResponse() {         
        string testListBucketResponse = 
            '<?xml version="1.0" encoding="UTF-8"?>'+ 
            '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>klklklk-test-bucket</Name><Prefix>'+
            '</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Contents><Key>/apex/adnDevSignup</Key>'+
            '<LastModified>2008-01-27T21:13:58.000Z</LastModified><ETag>&quot;630581ddc40fa0a3b7e521c67962baba&quot;</ETag><Size>27411</Size>'+
            '<Owner><ID>173ea00b3418d9a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID><DisplayName>vne</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apedfx/adnDevSignup</Key><LastModified>2008-01-31T09:50:41.000Z</LastModified>'+
            '<ETag>&quot;2d9ab36295e58d32db358aae0195c164&quot;</ETag><Size>27410</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnRoot</Key><LastModified>2008-01-31T09:50:40.000Z</LastModified>'+
            '<ETag>&quot;f956a9612c95c206f3208f023d1edefb&quot;</ETag><Size>20036</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-key-public</Key><LastModified>2008-02-02T04:02:59.000Z</LastModified>'+
            '<ETag>&quot;12f3e46f80c24c997c4304953edc3612&quot;</ETag><Size>32</Size><Owner><ID>99999999999</ID>'+
            '<DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-two</Key>'+
            '<LastModified>2008-02-02T00:40:29.000Z</LastModified><ETag>&quot;327b6f07435811239bc47e1544353273&quot;</ETag><Size>7</Size>'+
            '<Owner><ID>173</ID><DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';
        
        AWS_XMLDom d = new AWS_XMLDom(testListBucketResponse); 
        
        List<AWS_XMLDom.Element> keys = d.getElementsByTagName('Key');
        integer count= keys.size();
        system.assert(count > 1);
        
        AWS_XMLDom.Element p = keys[0].parentNode;
        p.removeChild(p.firstChild());
        
        keys = d.getElementsByTagName('Key');
        system.assert(keys.size() == count-1);
        
        keys = d.root.getElementsByTagName('Key');
        count = keys.size();
        system.assert(count > 1);
    }
     
    public static testmethod void testErrorResponse() {    
        string testErrorResponse = 
            '<?xml version="1.0" encoding="UTF-8"?>'+ 
            '<Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>test-key</Key><RequestId>49D135DD55EBD</RequestId>'+
            '<HostId>PB4hNZ</HostId></Error>';
    
        AWS_XMLDom d = new AWS_XMLDom(testErrorResponse); 
        List<AWS_XMLDom.Element> errors = d.getElementsByTagName('Error');
        system.assert(errors.size() == 1);
    }
    
    public static testmethod void testACLResponse() {
        string testACLResponse = 
            '<?xml version="1.0" encoding="UTF-8"?>'+ 
            '<AccessControlPolicy xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<AccessControlList><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser" foo="bar" ><ID>owner_id</ID>'+
            '<DisplayName>foobar</DisplayName></Grantee><Permission>FULL_CONTROL</Permission></Grant></AccessControlList></AccessControlPolicy>';
        AWS_XMLDom d = new AWS_XMLDom(testACLResponse); 
        system.assert(d.root.hasChildNodes()); 
        system.assert(d.root.isEqualNode(d.root) ,' is equal node');
        system.assert( d.root.textContent() == '' );
        system.assert( d.getElementsByTagName('Grantee')[0].hasAttributes() );
        system.assert( d.getElementByPath('bad') == null );   
        system.assert( d.getElementByTagName('badName') == null ); 
        system.assert( d.toXmlString() != null );   
    }
    
    public static testmethod void testRetrieveItem() { 
        AWS_XMLDom f = new AWS_XMLDom( '<RetrieveItem_Request_1 xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/Quotes_1"><ItemRequest Scope="All"><QoS xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon"><TimelinessInfo Timeliness="DELAYED" /><RateInfo Rate="UNSPECIFIED" /></QoS><Fields xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" /><RequestKey xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" Name="MSFT.O" Service="" NameType="RIC" /></ItemRequest></RetrieveItem_Request_1>');            
        system.assertEquals(f.toXmlString() != null, true);
    }
    
    public static testmethod void testNotificationTruncated() { 
         string testNotification = 
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
            '</book><book><title lang="eng">Learning ';
        AWS_XMLDom f = new AWS_XMLDom( testNotification );
        system.assert( f.getElementsByTagName('title')[0].nodeValue == 'Harry Potter' );
        system.assert( f.getElementsByTagName('title')[1].nodeValue == '' );
    }
    
    public static testmethod void testNotification() { 
         string testNotification = 
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
            '</book><book><title lang="eng">Learning XML</title><price>39.95</price></book></bookstore>';

        AWS_XMLDom d = new AWS_XMLDom(testNotification);  
        list<AWS_XMLDom.element> tmp ; 

        tmp =  d.root.getElementsByTagName('book');
        system.assertEquals(2, tmp.size()); 
        
        AWS_XMLDom.Element a = d.ownerDocument();
        AWS_XMLDom.Element f = a.firstChild();
        AWS_XMLDom.Element c = f.ownerDocument(); 
        system.assert(a.isSameNode(c));
        
        AWS_XMLDom.Element b = a.cloneNode();
        system.assert(!a.isSameNode(f) ); 
        
        a = new AWS_XMLDom.Element(); 
        system.assertEquals( a.firstChild(), null, ' must be null' );
        system.assertEquals( a.getElementByTagName('bad'), null);       
     }

    public static testmethod void testRSS() { 
        String feed = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<feed xmlns="http://purl.org/atom/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" version="0.3">'+
            '<title>Force.com Blog</title>' +
            '<link rel="alternate" type="text/html" href="http://blog.sforce.com/sforce/" />' +
            '<id>tag:typepad.com,2003:weblog-125619</id>' +
            '<link rel="service.post" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619" title="Force.com Blog" />' +
            '<modified>2008-01-23T20:27:30Z</modified>' +
            '<tagline></tagline>' +
            '<generator url="http://www.typepad.com/">TypePad</generator>' +
            '<info type="application/xhtml+xml">' +
            '<div xmlns="http://www.w3.org/1999/xhtml">This is an Atom formatted XML site feed. It is intended to be viewed in a Newsreader or syndicated to another site. Please visit <a href="http://blog.sforce.com/sforce/">Force.com Blog</a> for more info.</div>' +
            '</info><entry>' +
            '<title>Tour de Force Global Kickoff - it\'s a wrap!</title>' +
            '<link rel="alternate" type="text/html" href="http://feeds.feedburner.com/~r/SforceBlog/~3/221839184/tour-de-force-g.html" />' +
            '<link rel="service.edit" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619/entry_id=44564390" title="Tour de Force Global Kickoff - it\'s a wrap!" />' +
            '<id>tag:typepad.com,2003:post-44564390</id>' +
            '<issued>2008-01-23T12:27:30-08:00</issued>' +
            '<modified>2008-01-23T20:27:30Z</modified>' +
            '<created>2008-01-23T20:27:30Z</created>' +
            '<summary>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - we\'re delighted that you were able help us launch the Tour de Force roadshow to unleash the Force.com platform around...</summary>' +
            '<author><name>Mark Trang</name></author>' +
            '<content type="application/xhtml+xml" xml:lang="en-US" xml:base="http://blog.sforce.com/sforce/"><div xmlns="http://www.w3.org/1999/xhtml">'+
            '<p>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - </p></div></content>'+
            '<feedburner:origLink>http://blog.sforce.com/sforce/2008/01/tour-de-force-g.html</feedburner:origLink></entry></feed>';
        
        AWS_XMLDom d = new AWS_XMLDom(feed);  
        list<AWS_XMLDom.element> tmp ;  
        
        AWS_XMLDom.Element e2 = d.ownerDocument().getElementByTagName('entry');
        system.assertEquals('entry', e2.nodeName );         
        system.assertEquals( e2.getValue('title'), 'Tour de Force Global Kickoff - it\'s a wrap!');
        
        AWS_XMLDom.Element[] el = d.ownerDocument().getElementsByTagName('link');
        
        e2 = d.ownerDocument().getElementByTagName('name');
        System.assertEquals('Mark Trang', e2.nodeValue);
        
        e2 = d.ownerDocument().getElementsByPath('/feed/title')[0];
        
        el= d.ownerDocument().getElementsByPath('/feed/entry/.*');
        system.assertEquals( 14, el.size() );
        
        el= d.ownerDocument().getElementsByPath('/feed/entry');
        system.assertEquals( 1, el.size() );
        
        el= d.ownerDocument().getElementsByPath('/.*/entry.*');
        system.assertEquals( 15, el.size() );
    }
}