({
	afterRender: function(component, helper) {
        var value, svg = component.find("svg_content");
        value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value;        
    }
})