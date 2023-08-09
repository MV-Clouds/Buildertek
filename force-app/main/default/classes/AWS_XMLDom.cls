/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: AWS_XMLDom
* Created by Sagar: 06/05/2017
*
*
*   This class implements a small portion of the wc3 xml dom model.  
*   Generally useful for simple XML return objects. Note: stores namespaces 
*   in the attributes map for now. No node typing done at this time  
*   
*   can parse into DOM trees the XML return objects from Google, Amazon and others.
*   large parse trees will consume suprising amounts of memory
*
* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
public class AWS_XMLDom {
    // Everything in the dom is found as childNodes under this root element
    public Element root = new Element('#document');
    public integer debug =0;
    
    // Constructor 
    public AWS_XMLDom(string str) {
        parseFromString(str);
    }   
    public AWS_XMLDom() {
    }
    
    // Parse xml from string
    public void parseFromString(string str) {   
        XmlStreamReader reader = new XmlStreamReader(str);
        reader.setCoalescing(true);
        parseXmlReader(root,reader);    
    } 
    
    // Given a parent node and a stream reader, populates the tree below here (recursive)
    void parseXmlReader(Element parent, XmlStreamReader reader ) {
        try {
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                Element child = new Element( reader.getLocalName() );
                for(integer i=0; i<reader.getAttributeCount(); i++) { 
                    child.attributes.put(reader.getAttributeLocalName(i), reader.getAttributeValueAt(i) );
                }
                // Add namespace info to each node/element ( for now storing on attributes map)
                for (integer j=0; j<reader.getNamespaceCount(); j++) { 
                    string prefix = 'xmlns'; 
                    if (reader.getnamespaceprefix(j)!=null){
                         prefix = reader.getnamespaceprefix(j);
                    }
                    child.attributes.put(prefix , reader.getnamespaceuriat(j) );
                }
                parent.appendChild(child); // Add the new element to current parent
                reader.next();
                parseXmlReader(child, reader) ; // Recurse
            } else if (reader.getEventType() == XmlTag.END_ELEMENT) {   
                reader.next();
                return; 
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                if ( ! reader.isWhitespace()) { 
                    parent.nodeValue += reader.getText();  // add text to current element
                }
                reader.next();
            }
            else { 
                reader.next(); 
            }   
        }
        } catch(Exception e) { // ParseError if we get a truncated response, allow it
            system.debug(e);
        }
    }   
    
    // Access nodes in the tree using tag name
    public List<Element> getElementsByTagName(string nam) {
        return root.getElementsByTagName(nam); 
    }
    
    // Access nodes in the tree using path
    public List<Element> getElementsByPath(string path) {   
        return root.getElementsByPath( path);
    }
    
    // Access forst node in the tree using path
    public Element getElementByPath(string path) {  
        List<Element> r = root.getElementsByPath( path);
        if (r.size() == 0){
            return null;
        } else{ 
            return r[0];
        }
    }
    
    // Access forst node in the tree using tag name
    public Element getElementByTagName(string nam) {
        List<Element> r = root.getElementsByTagName(nam);
        if (r.size() == 0){
            return null;
        } else{
            return r[0];
        }
    }

    // Utility dom functions
    public Element ownerDocument() { 
        return root; 
    }
    
    // Covert root into string
    public String toXmlString() {
        return root.toXmlString(); 
    }
    
    /* 
        Element  class definition
     
        This following class implements a small portion of the wc3 xml dom model.  
        Generally useful for simple XML return objects. 
        
        For simplicity, Nodes are the same as Elements in this class.
        Nodes have text directly in them, rather than a seperate text node child
        The following describes the implemented portion, some w3c properties are now methods.   
    */  
    public class Element {
        public Element parentNode = null; 
        public string nodeName = ''; 
        public string nodeValue = ''; 
        public List<Element> childNodes = new List<Element>();
        public map<String,String> attributes = new map<String,String>();
        
        public Element(string n) {
            nodeName = n; 
        } 
        public Element() {
        }
        
        // Return attribure value
        public string getAttribute(string name) { 
            return attributes.get(name); 
        }
        
        // Adds a new child node to the end of the list of children of a node 
        public void appendChild(Element e) {
            e.ParentNode = this; 
            this.childNodes.add(e);     
        }
        
        // Removes a child node 
        public void removeChild(Element e) {
            Element p = e.parentNode;
            List<Element> kids = new List<Element> {};
            for( Element ee: e.parentNode.childNodes) {
                if (ee != e) 
                    kids.add(ee); 
            }
            p.childNodes = kids;
        }
        
        // Traverse below this node, returning all matching nodes by name
        public List<Element> getElementsByTagName(string nam) { 
            List<Element> ret = new List<Element>{};
            if (nam == this.nodeName){
                ret.add(this);
            }
            
            for(Element c: this.childNodes) { 
                ret.addAll(c.getElementsByTagName(nam));
            }
            return ret;
        }
        
        // Like above, but just returns the first one that matches  
        public Element getElementByTagName(string nam) {
            List<Element> r = getElementsByTagName(nam);
            if (r.size() == 0){
                return null;
            } else { 
                return r[0];
            }
        }
        
        // First one that matches, just return the nodeValue
        public string getValue(string nam) {
            Element e = getElementByTagName(nam); 
            return (e == null ? null : e.nodeValue); 
        }
        
        // Return string for element
        public string toXmlString() {
            string ret = '<' + this.nodeName + ' ';
            for(string a : attributes.keySet()) {
                ret += a + '=\'' + attributes.get(a) + '\' ' ;
            }
            if(nodeValue == '' && childNodes.size() == 0){ 
                return ret + ' />\n';   
            }
            ret += '>';
            if(nodeValue == '' ){ 
                ret += '\n';
            }
            integer hasChilds = 0;
            string tmpRet = '';
            for(Element c: this.childNodes) {  
                tmpRet += c.toXmlString() ;
                hasChilds++; 
            }
            if(hasChilds > 0 ){
                ret += tmpRet;
            }
            if(nodeValue != '' ){ 
                ret += nodeValue;
            }
            return ret + '</' + this.nodeName + '>\n'; 
        }
        
        // Returns list of elements matching tag name (document and element)
        public List<Element> getElementsByPath(string path) {   
            List<Element> ret = new List<Element>{};
            if(Pattern.matches(path, this.path())){
                ret.add(this);
            }
            for(Element c: this.childNodes){
                ret.addAll(c.getElementsByPath(path));
            }
            return ret;
        }
        
        // Return path of the active node
        public string path() { 
            Element t = this;
            string ret = t.nodeName; 
            while(t.parentNode != null && t.parentNode.nodeName != '#document') { 
                t = t.parentNode;
                ret = t.nodeName + '/'+ret;
            }
            return '/'+ret;
        }
        
        // Returns the first child of a node    
        public Element firstChild() { 
            if ( this.childNodes.size() == 0 ) return null; 
            return this.childNodes[0]; 
        }
        
        // Returns the textual content of a node
        public string textContent() { return this.nodeValue; } 
        
        // Returns whether the element has any child nodes 
        public Boolean hasChildNodes() { return childNodes.size()>0; }
        
        // Checks if two nodes are equal 
        public Boolean isEqualNode(Element comp) { return this.nodeName == comp.nodeName; } 
        
        // Clones a node 
        public Element cloneNode() { return this.clone(); } 
        
        // Returns whether the element has any attributes 
        public Boolean hasAttributes() { return ! attributes.isEmpty(); } 
        
        // Checks if two nodes are the same node 
        public Boolean isSameNode(Element comp) { return this === comp; }       
        
        // Returns the root element (document object) for a node 
        public Element ownerDocument() { 
            Element ret = this; 
            while( ret.parentNode != null) { ret = ret.parentNode; }            
            return ret; 
        } 
    }
}