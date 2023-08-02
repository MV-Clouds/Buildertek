({
    buildOrgChart: function(component, helper) {
          var Id = window.location.href.split("/").pop();
        Id=Id.split("?")[0];
      var action = component.get("c.getParent_SubOrdinateUsers");
       action.setParams({
      "userId": Id,
    });
      action.setCallback(this, function(response) {
             var state = response.getState();
             var treeData = JSON.parse(response.getReturnValue());
             console.log(response.getReturnValue());
             var data = helper.buildDataObject(component, helper, treeData);
             // Set the dimensions and margins of the diagram
             var margin = {
                 top: 150,
                 right: 100,
                 bottom: 100,
                 left: -400
               },
               width = 1000 - margin.left - margin.right,
               height = 1250 - margin.bottom;;

             // declares a tree layout and assigns the size
             var treemap = d3.tree().size([height, width]);
             // append the svg object to the body of the page
             // appends a 'group' element to 'svg'
             // moves the 'group' element to the top left margin

             var zoom = d3.zoom()
               .scaleExtent([-100, 100])
               .on('zoom', zoomFn);

             var svg = d3.select("#body").append("svg")
               .attr("width", width + margin.right + margin.left)
               .attr("height", height + margin.top + margin.bottom);

             function zoomFn() {
               d3.select('#body').select('svg').select('g')
                 .attr('transform', 'translate(' + d3.event.transform.x + ',' + d3.event.transform.y + ') scale(' + d3.event.transform.k + ')');
             }

             svg.call(zoom);

             svg = svg
               .append("g")
               .attr("transform", "translate(" +
                 margin.left + "," + margin.top + ")");



             var i = 0,
               duration = 750,
               root;

             // Assigns parent, children, height, depth
             root = d3.hierarchy(data, function(d) {
               return d.children;
             });
             root.x0 = height / 2;
             root.y0 = 0;

             // Collapse after the second level
             root.children.forEach(collapse);
             update(root.data);
             loadImages(root.data);

             // Collapse the node and all it's children
             function collapse(d) {
               if (d.children) {
                 d._children = d.children
                 d._children.forEach(collapse)
                 d.children = null
               }
             }

             function loadImages(source) {
               var images = [{
                 id: source.id,
                 tb: source.tb
               }];
               if (source.children) {
                 $.each(source.children, function(index, value) {
                   images.push({
                     id: value.id,
                     tb: value.tb
                   });
                   if (value.children) {
                     $.each(value.children, function(j, v1) {
                       images.push({
                         id: v1.id,
                         tb: v1.tb
                       });
                     });
                   }
                 });
               }
               $.each(images, function(index, value) {
                 if (!value.id || !value.tb) return;
                 svg.append("svg:defs")
                   .append("svg:pattern")
                   .attr("id", value.id)
                   .attr("width", 100)
                   .attr("height", 100)
                   .attr("patternUnits", "userSpaceOnUse")
                   .append("svg:image")
                   .attr("xlink:href", value.tb)
                   .attr("width", 100)
                   .attr("height", 100)
                   .attr("x", 0)
                   .attr("y", 0);
               });
             }

             function update(source) {
               // Assigns the x and y position for the nodes
               var treeData = treemap(root);
               // Compute the new tree layout.
               var nodes = treeData.descendants(),
                links = treeData.descendants().slice(1);
               // Normalize for fixed-depth.
               nodes.forEach(function(d) {
                 d.y = d.depth * 150
               });
               // ****************** Nodes section ***************************
               // Update the nodes...
               var node = svg.selectAll('g.node')
                 .data(nodes, function(d) {
                   return d.data.id || (d.id = ++i);
                 });
               // Enter any new modes at the parent's previous position.
               var nodeEnter = node.enter().append('g')
                 .attr('class', 'node')
                 .attr("transform", function(d) {
                   return "translate(" + (source.x0) + "," + (source.y0) + ")";
                 })
                 .on('click', click);
               // Add Circle for the nodes
               nodeEnter.append('circle')
                 .attr("cx", 50)
                 .attr("cy", 50)
                 .attr("r", 50)
                 .attr("fill", function(d) {
                   return "url(#" + d.data.id + ")";
                 })
                 .attr("stroke", "#2574a9")
                 .attr("stroke-width", "3")
                 .attr("filter", "url(#boxShadow)")
                 .on("mouseover", function(d) {
                   var tooltip = d3.selectAll("[id='" + d.data.id + "tooltip" + "']");
                   tooltip.style("opacity", "1");
                 })
                 .on("mouseout", function(d) {
                   var tooltip = d3.selectAll("[id='" + d.data.id + "tooltip" + "']");
                   tooltip.style("opacity", "0");
                 });
               nodeEnter.append("circle")
                 .attr("cx", 50)
                 .attr("cy", 50)
                 .attr("r", 50)
                 .attr("fill", function(d) {
                   return (d.children || d._children || d.hasChild) ? "url(#gradientchilds)" : "url(#gradientnochilds)";
                 })
                 .style("cursor", function(d) {
                   return (d.children || d._children || d.hasChild) ? "pointer" : "default";
                 })
                 .attr("class", "box");

               var tooltip = nodeEnter.append("g")
                 .attr("class", "tooltip css")
                 .attr("id", function(d) {
                   return d.data.id + "tooltip";
                 });

               tooltip.append("rect")
                 .attr("width", "12em")
                 .attr("height", "6em")
                 .attr("rx", "10")
                 .attr("ry", "10")
                 .attr("x", "-6.75em")
                 .attr("y", "-7em");

               var tooltipTextBox = tooltip.append("text")
                 .attr("text-anchor", "start")
                 .attr("alignment-baseline", "middle")
                 // .attr("dx", "-7rem")
                 .attr("y", "-5.85rem");

               tooltipTextBox.append("tspan")
                 .attr("class", "tooltip-name")
                 .attr("x", "-5.25rem")
                 .attr("dy", "1.05rem")
                 .html(function(d) {
                   return d.data.fullname;
                 });

               tooltipTextBox.append("tspan")
                 .attr("class", "tooltip-title")
                 .attr("x", "-5.25rem")
                 .attr("dy", "1.05rem")
                 .html(function(d) {
                   return d.data.desc;
                 });

               tooltipTextBox.append("tspan")
                 .attr("class", "tooltip-telephone")
                 .attr("x", "-5.25rem")
                 .attr("dy", "1.05rem")
                 .html(function(d) {
                   return d.data.phone;
                 });

               tooltipTextBox.append("tspan")
                 .attr("class", "tooltip-emailaddress")
                 .attr("x", "-5.25rem")
                 .attr("dy", "1.05rem")
                 .html(function(d) {
                   return d.data.email;
                 });

               nodeEnter.append("path")
                 .attr("d", "M 5,75 C 25,110 75,110 95,75")
                 .attr("fill", "#2574a9");

               nodeEnter.append("text")
                 .attr("x", 50 / 2)
                 .attr("y", 50 + 12)
                 .attr("dy", "2.35em")
                 .attr("dx", "2.15em")
                 .attr("text-anchor", "middle")
                 .style("cursor", function(d) {
                   return (d.children || d._children || d.hasChild) ? "pointer" : "default";
                 })
                 .text(function(d) {
                   return d.data.name;
                 });

               nodeEnter.append("text")
                 .attr("class", "children")
                 .attr("x", 50 / 2)
                 .attr("y", 50 + 60)
                 .attr("dy", ".65em")
                 .attr("dx", "1.15em")
                 .attr("text-anchor", "middle")
                 .style("cursor", function(d) {
                   return (d.children || d._children || d.hasChild) ? "pointer" : "default";
                 })
                 .text(function(d) {
                   if (d.children && d.children.length > 0)
                     return d.children.length;
                   if (d._children && d._children.length > 0)
                     return d._children.length;

                   return '';
                 });

               nodeEnter.append("polygon")
                 .attr("points", "34,128 64,128 49,143")
                 .attr("fill", "#2574a9")
                 .attr("id", function(d) {
                   return d.data.id + "expandTriangle";
                 })
                 .attr("fill-opacity", function(d) {
                   if (d.children && d.children.length > 0)
                     return 100;

                   if (d._children && d._children.length > 0)
                     return 100;

                   return 0;
                 });

               // UPDATE
               var nodeUpdate = nodeEnter.merge(node);
               // Transition to the proper position for the node
               nodeUpdate.transition()
                 .duration(duration)
                 .attr("transform", function(d) {
                   return "translate(" + (d.x - 50) + "," + (d.y - 50) + ")";
                 });
               // Update the node attributes and style
               nodeUpdate.select('g.node')
                 .attr("id", function(d) {
                   return d.id;
                 })
                 .attr('cursor', 'pointer');
               // Remove any exiting nodes
               var nodeExit = node.exit().transition()
                 .duration(duration)
                 .attr("transform", function(d) {
                   return "translate(" + (source.x - 50) + "," + (source.y - 50) + ")";
                 })
                 .remove();

               // ****************** links section ***************************
               // Update the links...
               var link = svg.selectAll('path.link')
                 .data(links, function(d) {
                   return d.data.id;
                 });
               // Enter any new links at the parent's previous position.
               var linkEnter = link.enter().insert('path', "g")
                 .attr("class", "link")
                 .attr("x", "50")
                 .attr("y", "50")
                 .attr('d', function(d) {
                   var o = {
                     x: source.x0,
                     y: source.y0
                   }
                   return diagonal(o, o)
                 });
               // UPDATE
               var linkUpdate = linkEnter.merge(link);
               // Transition back to the parent element position
               linkUpdate.transition()
                 .duration(duration)
                 .attr('d', function(d) {
                   return diagonal(d, d.parent)
                 });
               // Remove any exiting links
               var linkExit = link.exit().transition()
                 .duration(duration)
                 .attr('d', function(d) {
                   var o = {
                     x: source.x,
                     y: source.y
                   }
                   return diagonal(o, o)
                 })
                 .remove();
               // Store the old positions for transition.
               nodes.forEach(function(d) {
                 d.x0 = d.x;
                 d.y0 = d.y;
               });
               // Creates a curved (diagonal) path from parent to the child nodes
               function diagonal(s, d) {
                 var path = 'M ' + s.x + ' ' + s.y +
                 ' C ' + s.x + ' ' + ((s.y + d.y) / 2)
                 + ', ' + d.x + ' ' + ((s.y + d.y) / 2)
                 + ', ' + d.x + ' ' + (d.y);
                 return path;
               }
               // Toggle children on click.
               function click(d) {
                 if (d.children) {

                   d._children = d.children;
                   d.children = null;
                 } else {
                   d.children = d._children;
                   d._children = null;
                 }
                 update(d);
                 loadImages(d);
               }
             }
        });
      $A.enqueueAction(action);


  },

  buildDataObject: function(component, helper, response) {
    var data = {};
      console.log('Res-->'+JSON.stringify(response['mUsr']));
    if(!$A.util.isEmpty(response['mUsr']) && !$A.util.isEmpty(response['mUsr'].Name)){
        
      data = helper.buildUserObject(component, helper, response['mUsr']);
      data.hasChild = true;
      data.children = [];
      data.children.push(helper.buildUserObject(component, helper, response['usr'], response['subordinates']));
    } else {
       
      data = helper.buildUserObject(component, helper, response['usr'], response['subordinates']);
    }
    console.log(JSON.stringify(data));
    return data;
  },

  buildUserObject: function(component, helper, userObj, subOrdinates){
    if($A.util.isEmpty(userObj)) return;

    var user = {
      "id": userObj.Id,
      "fullname": userObj.Name,
      "name": userObj.FirstName + '. ' + userObj.LastName.charAt(0),
      "email": userObj.Email,
      "desc": userObj.Title,
      "phone": userObj.Phone,
      "tb": userObj.FullPhotoUrl
    };

    if($A.util.isEmpty(subOrdinates)) { user.hasChild = false; return user };

    user.hasChild = true;
    var children = [];
    subOrdinates.forEach(function(usr){
      children.push(helper.buildUserObject(component, helper, usr));
    });
    user.children = children;

    return user;
  }
})