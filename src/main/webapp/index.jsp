<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,  org.json.JSONObject, com.wayos.*, com.wayos.util.Application, com.wayos.connector.SessionPool" %>
<!doctype html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang=""> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8" lang=""> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9" lang=""> <![endif]-->
<!--[if gt IE 8]><!-->
<%@ include file="i18n.jspf"%>
<html class="no-js" lang="">
<!--<![endif]-->
<head>
<title>WAYOS</title>
<% 
	String contextRoot = application.getContextPath();
	String accountId = (String) request.getAttribute("accountId");
	String botId = (String) request.getAttribute("botId");	
	JSONObject properties = (JSONObject) request.getAttribute("props");
	/**
	* Default contextName
	*/
	boolean isShowcase = false;
	if (accountId == null || botId == null) {
		
		accountId = System.getenv("showcaseAccountId");		
		if (accountId==null) {
			accountId = "";
		}
		
		botId = System.getenv("showcaseBotId");
		if (botId==null) {
			botId = "";
		}

		String contextName = accountId + "/" + botId;
		try {
			
			SessionPool sessionPool = Application.instance().get(SessionPool.class);			
			Context context = sessionPool.getContext(contextName);			
			context.load();

			/**
			* filter only title, desc, borderColor & loadingGif
			*/
			properties = new JSONObject(context.prop());
			properties.remove("greeting");
			properties.remove("silent");
			properties.remove("unknown");
						
		} catch (Exception e) {
			
			throw new RuntimeException(e);
			
		}
				
		isShowcase = true;
	}	
%>

<script>
var domain = '<%= Configuration.domain %>';
var contextRoot = '<%= contextRoot %>';
</script>

<%@ include file="css.jspf" %>


<style>
body, div, section, iframe {
	touch-action: none;
}
.eossTextArea {
	width: 98%;
	border: 1px solid #DDDDDD;
	-webkit-box-sizing: border-box; /* Safari/Chrome, other WebKit */
	-moz-box-sizing: border-box; /* Firefox, other Gecko */
	box-sizing: border-box;  
	font-size: 16px;
}
.eossFileButton {
    width: 8%;
	border: 1px solid #DDDDDD;
   	background: #3498db;
    color: white;
   	line-height: 40px;
    margin-bottom: 10px;
}
.eossButton {
    width: 45%;
	border: 1px solid #DDDDDD;
   	background: #3498db;
    color: white;
   	line-height: 40px;
    margin-bottom: 10px;
}
.context {
	margin: 0;
	padding: 10px 0;
	width: 100%;
}
.footer {
   position: fixed;
   left: 0;
   bottom: 0;
   width: 100%;
   text-align: center;
}
</style>

<meta property="fb:app_id" content="<%= System.getenv("facebook_appId") %>" />

<meta property="og:type" content="website" />
<meta property="og:title" content="<%= properties.optString("title") %>" />
<meta property="og:description" content="<%= properties.optString("description") %>" />
<meta property="og:url" content="<%= request.getScheme() + "://" + Configuration.domain + contextRoot %>/x/<%= accountId %>/<%= botId %>" />
<meta property="og:image" content="<%= request.getScheme() + "://" + Configuration.domain + contextRoot %>/public/<%= accountId %>/<%= botId %>.PNG" />
<meta property="og:image:alt" content="<%=  request.getScheme() + "://" + Configuration.domain + contextRoot %>/images/gigi.png" />

</head>
<body>

<div id="fb-root"></div>

<script async defer crossorigin="anonymous" src="https://connect.facebook.net/th_TH/sdk.js#xfbml=1&version=v3.2&appId=477788152679063&autoLogAppEvents=1"></script>

<!--[if lt IE 8]>
	<p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
<![endif]-->
	<div class='preloader'>
		<div class='loaded'>&nbsp;</div>
	</div>
	<%@ include file="nav-bar.jspf"%>
		
	<section class="context">
		<div class="col-md-12" style="text-align: center; padding: 0; touch-action: none">
			<iframe id="wayos-frame" frameborder="0" scrolling="no" allowfullscreen></iframe>
				<p class="footer">
					<textarea id="inputTextArea" class="eossTextArea" rows="3" cols="55" placeholder="<fmt:message key="textarea.typehere" />"></textarea><br>
					<input type="file" id="fileDialog" style="display: none">
					<button id="fileButton" class="eossFileButton">🖼</button><button id="ringButton" class="eossButton" >🔔</button><button id="sendButton" class="eossButton">SEND</button>
				</p>
		</div>
	</section>
		
	<%@ include file="overlay.jspf" %>
	<%@ include file="javascript.jspf" %>	
	<%@ include file="fbSDK.jspf" %>

	<script>
	function showNotification(title, body, url) {
		const notification = new Notification(title, {body});
		notification.onclick = (e) => {
			window.location.href = url;
		};
	}
		
	const FRAME_HEIGHT = "59vh";
	var inputTextArea = document.getElementById("inputTextArea");
	var fileButton = document.getElementById("fileButton");
	var ringButton = document.getElementById("ringButton");
	var sendButton = document.getElementById("sendButton");
	
	inputTextArea.disabled = true;
	fileButton.disabled = true;
	ringButton.disabled = true;
	sendButton.disabled = true;
	
	function showLoading(display) {
		
		let element = document.getElementById("loader");
		if (display) {
			element.style.display = "block";
		} else {
			element.style.display = "none";
		}
	}
	
	function toggleMenuBar() {
    	if ($('.navbar-toggle').css('display') != 'none') {
    		$('.navbar-toggle').trigger("click");
        }		
	}
	
	function localSessionId() {
		
		var sessionId = localStorage.getItem("sessionId");
		if (sessionId==null) {
			sessionId = Date.now().toString();
			localStorage.setItem("sessionId", sessionId);
		}
		
		return sessionId;
	}
	
	var wayOS = {
		sessionId: localSessionId(),
		accountId: "<%= accountId %>",
		botId: "<%= botId %>"
	};
	
	wayOS.adjustFrameHeight = function(width, height) {
		
		let frame = document.getElementById("wayos-frame");
		if (frame) {
			frame.style.height = (1140 * (height / width)) + 'px';
		}
	}
	
	wayOS.onDisplayImage = function(imageURL, next) {
		
		let frame = document.getElementById("wayos-frame");
		if (frame) {
			frame.src = "";
		}
		
		this.showBackground(imageURL, next);
	}
	
	wayOS.onDisplayImageInFrame = function(imageURL, next) {

		if (next) {
			wayOS.next = next;
		}
		
		let frame = document.getElementById("wayos-frame");	
		if (frame) {
			const src = frame.src;
			frame.onload = function() {
			}
			frame.onerror = function () {
				this.src = src;
			}			
			frame.src = contextRoot + "/panel.jsp?img=" + encodeURIComponent(imageURL);
		}
		
	}

	wayOS.onDisplayYoutube = function(youtubeId, next) {
		
		let frame = document.getElementById("wayos-frame");	
		if (frame) {
			const src = frame.src;
			frame.onerror = function () {
				this.src = src;
			}
			frame.src = "https://www.youtube.com/embed/" + youtubeId;
		}
		
		if (next) {
			next();
		}
	}

	wayOS.onDisplayWeb = function(url, next) {
		
		console.log("onDisplayWeb: " + url);
		
		let frame = document.getElementById("wayos-frame");
		if (frame /*&& (url.startsWith("https://wayobot.com") || url.startsWith("https://www.wayobot.com"))*/) {
			const src = frame.src;
			frame.onload = function () {
				this.style.height = this.contentDocument.body.offsetHeight + 'px';			
				this.onload = null;
				if (next) {
					next();
				}		
			}
			frame.onerror = function () {
				this.src = src;
			}
			frame.src = url;
		}
		
	}

	wayOS.onDisplayCatalog = function(innerHTML, next) {
		
		let frame = document.getElementById("wayos-frame");
		if (frame) {
			const src = frame.src;
			frame.onload = function() {
				
				//Slide Menus
				if (innerHTML.indexOf("inline-block")!==-1) {
					this.contentDocument.body.innerHTML = "<div align=\"center\" class=\"vertical-center\"><p>" + innerHTML.replace(/width: 80/g, "width: 50") + "</p></div>";					
				} 
				//Single Menu
				else {
					this.contentDocument.body.innerHTML = "<div align=\"center\" class=\"vertical-bottom\"><p>" + innerHTML + "</p></div>";
				}
				
				this.style.width = "100%";
				this.style.height = FRAME_HEIGHT;
				this.onload = null;
				
				//Focus text area if there is no choices!
				if (innerHTML.indexOf("wayos_menu_item")===-1) {
				    inputTextArea.focus();					
				}
				
				if (next) {
					next();
				}
			}
			frame.onerror = function () {
				this.src = src;
			}
			
			if (src) {
				frame.src += '';
				return;
			}
			
			frame.src = contextRoot + "/panel.jsp";
		}
		
	}
	
	wayOS.onDisplayText = function(text, next) {

		let innerHTML = "<div align=\"center\" class=\"vertical-center\"><h1 class=\"wayos_label\">" + text + "</h1></div>";
		let frame = document.getElementById("wayos-frame");
		if (frame) {
			const src = frame.src;
			frame.onload = function() {
				this.contentDocument.body.innerHTML = innerHTML;
				this.style.width = "100%";
				this.style.height = FRAME_HEIGHT;
				this.onload = null;
				
				if (next) {
					next();
				}
			}
			frame.onerror = function () {
				this.src = src;
			}
			
			if (src) {
				frame.src += '';
				return;
			}
			
			frame.src = contextRoot + "/panel.jsp";
		}
		
	}
	
	wayOS.animateResponseText = function(message) {
		
		if (message === "") return;
		
		let texts = message.split('\n\n\n');
	
		/**
		* Display Simple Animation on wayos-frame
		*/
		setTimeout(function() {
			
			const callee = arguments.callee.bind(this);
			
			function next() {
				
				setTimeout(callee, 500);
				
			};
			
			let text = texts.shift();
			
			if (!text) return;
			
			console.log("Show:" + text);
			
		    //if (text.indexOf('<div style="overflow: auto; white-space: nowrap;">')!==-1) {
			 if (text.indexOf('<div')!==-1) {
		        	
		    	this.onDisplayCatalog(text, next);
		    	
		    } else if (text.startsWith("https://") || text.startsWith("http://")) {
		    	
	        	var checkTxt = text.toLowerCase();
	        	
	        	if (checkTxt.endsWith("jpg") || checkTxt.endsWith("jpeg") || checkTxt.endsWith("png")) {
	        	
			        this.onDisplayImage(text, next);
			        
	        	} else if (checkTxt.endsWith("gif")) {
	        		
 		        	this.onDisplayImageInFrame(text, next);
 		        	
	        	} else if (text.startsWith("https://www.youtube.com/watch?v=")) {
 		        		
 		        	let x = text.replace("https://www.youtube.com/watch?v=", "");
 		        		
 		        	if (x.indexOf(" target")>0) {
 		        			
 		        		this.onDisplayYoutube(x.substr(0, x.indexOf(" target") - 1), next);
 		        			
 		        	} else {
 		        			
 		        		this.onDisplayYoutube(x, next);
 		        			
 		        	}
 		        		
 		        } else if (text.startsWith("https://i3.ytimg.com/vi/")) {
 		        		
		        	this.onDisplayYoutube(url.replace("https://i3.ytimg.com/vi/", "").replace("/maxresdefault.jpg", ""), next);
 		        		
 		        }

		    } else {
		    	
		      this.onDisplayText(text, next);
		    	
		    }
			 
		}.bind(this), 0);
	}
		
	wayOS.dropFile = function() {
		
		const input = document.getElementById("fileDialog");
		
		const files = Array.from(input.files);
		
		showLoading(true);
		
        let formData = new FormData();
        
        let fileNames = "";
        let totalSize = 0;
        
        for (let i in files) {
    		formData.append('file', files[i]);
    		totalSize += files[i].size;
    		fileNames += files[i].name + " ";
        }
        
 		let xhr = new XMLHttpRequest();
 		
 		let url = contextRoot + "/webhooks/" + this.accountId + "/" + this.botId + "/" + this.sessionId;
 		
 		xhr.open("POST", url); 
 		
 		xhr.onload = function() {
 			
 		    if (xhr.status === 200) {
 		    	
 		    	showLoading(false);
 				
 		    	this.animateResponseText(xhr.responseText);
 		    	
 		    }
 			
 		}.bind(this);
 		
 		xhr.send(formData);	
 	}
	
	wayOS.parse = function(message, success) {
		
		showLoading(true);
		
		let xhr = new XMLHttpRequest();
 		let url = contextRoot + "/webhooks/" + this.accountId + "/" + this.botId;
 		
 		let params = "message=" + message + "&sessionId=" + this.sessionId;
 		
 		xhr.open("POST", url, true);
 		xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

 		xhr.onload = function() {
 			
 		    if(xhr.status === 200) {
 		    	 	            
 		    	showLoading(false);
 		    	
 		    	console.log("Response Start: ");
 		    	console.log(xhr.responseText);
 		    	console.log("Response End: ");
 		    	
 		    	this.animateResponseText(xhr.responseText);
 		    	
 		    	if (success) {
 		    		success();
 		    	}
 		    }
 		    
 		}.bind(this);
 		
 		xhr.send(params);
	}
	
	wayOS.createRichMenuItem = function(key, value) {
		
		let li = document.createElement("li");
		li.className = "login";
		
		let a = document.createElement("a");
		a.innerHTML = key;
		a.href = "javascript:wayOS.parse('" + value + "', toggleMenuBar)";
		a.style.width = "150px";
		
		li.appendChild(a);
		
		return li;
	}
	
	wayOS.showBackground = function(imageURL, next) {
		
		let backgroundSize = "contain";
		//Set to Default Background
		if (!imageURL) {
			imageURL = contextRoot + "/public/" + this.accountId + "/" + this.botId + ".PNG";
			backgroundSize = "cover";
		}
		
		document.body.style.backgroundImage = "url('" + imageURL + "')";
		document.body.style.backgroundRepeat = "no-repeat";
		document.body.style.backgroundSize = backgroundSize;
		document.body.style.backgroundPosition = "center";
		document.body.style.backgroundColor = this.config.borderColor;
		
		if (next) {
			const interval = imageURL.indexOf("https://eoss-setfin") === -1 ? 500 : 2500;
			const image = new Image();
			image.onload = function () {
				//Add more delay for image display
				setTimeout(function() {
					
					next();
					
				}, interval);
			}
			image.src = imageURL;
		}

	}
	
	wayOS.applyTheme = function(config) {
				
		document.addEventListener('touchstart', function(e) {e.preventDefault()}, false);
		document.addEventListener('touchmove', function(e) {e.preventDefault()}, false);		
		
		let titleHeader = document.getElementById("title");
   		titleHeader.innerHTML = config.title;
   		
		let titleLink = document.getElementById("title_link");		
		let titleURI = contextRoot + "<%= isShowcase ? "/" : "/x/" + accountId + "/" + botId %>";
		titleLink.setAttribute("href", titleURI);
   		
	  	let socialSection = document.getElementById("social");
 	  	socialSection.style.background = config.borderColor;
 	  	
  		let loading = document.getElementById("loading");
 	  	if (config.loadingGif) {

 	  		loading.classList.remove("loader");
 	  		loading.classList.add("gifLoader"); 	  		
 	  		loading.style.backgroundImage = "url('" + config.loadingGif + "')";
 	  		
 	  	} else {
 	  		
 	  		loading.classList.remove("gifLoader");
 	  		loading.classList.add("loader");
 	  		loading.style.backgroundImage = "";
 	  		
 	  	}
   		
	   	let richMenus = document.getElementById("richMenus");
	   	
		//richMenus.appendChild(this.createRichMenuItem("🔔", "greeting"));
		
   		if (config.richMenus) {
   			
   			let items = config.richMenus.split(',');
   			
   			for (let i in items) {
   				
   				let item = items[i].trim();
   				
   				richMenus.appendChild(this.createRichMenuItem(item, item + "!"));
   			}
   		
   		}
 	  	 	  		
 	  	let liElements = document.querySelectorAll("li.login");
 	  	let buttonElement;
 	  	for (let i in liElements) {
 	  	
	  		if (liElements[i].style) continue; //Skip Fb Login
	  		
 	  		try {
 	  			
 	  			buttonElement = liElements[i].children[0];
	 	 		 	  			
   				buttonElement.style.color = config.borderColor;
   				buttonElement.style.borderColor = config.borderColor;
   				buttonElement.style.backgroundColor = "WHITE";
	 	  			
 			} catch (e) {
 	  				
   			}
   		}
 	  	
 		inputTextArea.disabled = false;
 		inputTextArea.autofocus = true;
 		
 		fileButton.disabled = false;
 		fileButton.style.color = "WHITE";
 		fileButton.style.backgroundColor = config.borderColor;
 	  	
 		ringButton.disabled = false;
 	  	ringButton.style.color = "WHITE";
 	  	ringButton.style.backgroundColor = config.borderColor;
 	  	
 		sendButton.disabled = false;
 	  	sendButton.style.color = "WHITE";
 	  	sendButton.style.backgroundColor = config.borderColor;
 	  	
 	  	fileButton.addEventListener('click', function() {
 	  		let fileDialog = document.getElementById("fileDialog");
 	  		fileDialog.onchange = function () {
 	 	  		this.dropFile();
 	  		}.bind(this);
 	  		fileDialog.click();
 	  	}.bind(this));
 	  	
 		ringButton.addEventListener('click', function(event) {
 			this.showBackground();
            var message = "greeting";
			this.parse(message);
	    }.bind(this));
 		
 		sendButton.addEventListener('click', function(event) {
            var message = inputTextArea.value.trim();
			if (message != '') {
				this.parse(message, function() {
					inputTextArea.value = "";
				});
			}
	    }.bind(this));
 		
 		this.config = config;
 		
		this.showBackground();
 		
	}

	wayOS.lazyLoad = function() {

		showLoading(true);
		
 		let url = contextRoot + "/props/" + this.accountId + "/" + this.botId;
 		
	 	var xhr = new XMLHttpRequest();
	 	xhr.open("GET", url, true);
	 	
	 	xhr.onload = function() {
	 		
	 	  	if (xhr.status === 200) {
	 	  		
	 			showLoading(false);
	 			
	 	  		this.applyTheme(JSON.parse(xhr.responseText));
	 	  		
	 	  		this.parse("greeting");	 	  		
	 		}

	 	}.bind(this);
	 	
	 	xhr.send();
    }
	
	wayOS.quickLoad = function() {
		
		const props = '<%=properties.toString().replace("'", "\\'")%>';
		
		this.applyTheme(JSON.parse(props));
 	  		
 	  	this.parse("greeting");

    }
	
	wayOS.quickLoad();
	
	</script>
	
</html>