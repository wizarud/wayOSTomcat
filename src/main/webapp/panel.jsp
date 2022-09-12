<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<%
	String imgPath = request.getParameter("img");
%>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="css/wayos.css" />
<style type="text/css">
div.vertical-center, p {
	touch-action: none;
}
.wayos_image_head {
	cursor: pointer;
    width: 90%;
    height: 70vh;
	margin: 0px auto;
    border-radius: 15px;
    -moz-border-radius: 15px;
    -webkit-border-radius: 15px;
    background-position: center; 
    background-repeat: no-repeat;
    background-size: cover;
}
.vertical-center {
	margin: 0;
	position: absolute;
	width: 100%;
	top: 50%;
	-ms-transform: translateY(-50%);
	transform: translateY(-50%);
}
.vertical-bottom {
	margin: 0;
	position: absolute;
	width: 100%;
	bottom: 0;
}

<% if (imgPath!=null) { %>

body {
  /* The image used */
  background-image: url("<%= imgPath %>");

  /* Full height */
  height: 100vh; 

  /* Center and scale the image nicely */
  background-position: center;
  background-repeat: no-repeat;
  background-size: contain;
}

<% } %>

</style>
<script>

const wayOS = parent.wayOS;
const style = document.createElement('style');
style.textContent = ".wayos_label { cursor: pointer; width: 80%; border-radius: 15px; -moz-border-radius: 15px; -webkit-border-radius: 15px; padding: 2px 10px; color: white; background: " + wayOS.config.borderColor + " } .wayos_menu_item { cursor: pointer; width: 80%; margin: 5px; padding: 5px 10px; border-radius: 5px; -moz-border-radius: 5px; -webkit-border-radius: 5px; background: #FFFFFF; text-align: center; color: " + wayOS.config.borderColor + "; border: 1px solid " + wayOS.config.borderColor + " }";

document.head.appendChild(style);

</script>
</head>
<body style="margin: 0px !important;">
<div id="content" class="vertical-center">
</div>

<% if (imgPath!=null) { %>
<script>
	window.onload = function (e) {
		if (parent && parent.wayOS) {
			
			const image = new Image();
			image.onload = function () {
				//parent.wayOS.adjustFrameHeight(this.width, this.height);
				if (parent.wayOS.next) {
					
					//Add more delay for image display
					setTimeout(function() {
						
						parent.wayOS.next();
						delete parent.wayOS.next;
						
					}, 2500);
				}
			}
			
			image.src = "<%= imgPath %>";
			
		}
	}
</script>
<% } %>
</body>
</html>