try {
window.AG_onLoad = function(func) { if (window.addEventListener) { window.addEventListener('DOMContentLoaded', func); } };
window.AG_removeElementById = function(id) { var element = document.getElementById(id); if (element && element.parentNode) { element.parentNode.removeChild(element); }};
window.AG_removeElementBySelector = function(selector) { if (!document.querySelectorAll) { return; } var nodes = document.querySelectorAll(selector); if (nodes) { for (var i = 0; i < nodes.length; i++) { if (nodes[i] && nodes[i].parentNode) { nodes[i].parentNode.removeChild(nodes[i]); } } } };
window.AG_each = function(selector, fn) { if (!document.querySelectorAll) return; var elements = document.querySelectorAll(selector); for (var i = 0; i < elements.length; i++) { fn(elements[i]); }; };
var AG_removeParent = function(el, fn) { while (el && el.parentNode) { if (fn(el)) { el.parentNode.removeChild(el); return; } el = el.parentNode; } };
var AG_onLoad=function(func){if(document.readyState==="complete"||document.readyState==="interactive")func();else if(document.addEventListener)document.addEventListener("DOMContentLoaded",func);else if(document.attachEvent)document.attachEvent("DOMContentLoaded",func)};
var AG_removeElementById = function(id) { var element = document.getElementById(id); if (element && element.parentNode) { element.parentNode.removeChild(element); }};
var AG_removeElementBySelector = function(selector) { if (!document.querySelectorAll) { return; } var nodes = document.querySelectorAll(selector); if (nodes) { for (var i = 0; i < nodes.length; i++) { if (nodes[i] && nodes[i].parentNode) { nodes[i].parentNode.removeChild(nodes[i]); } } } };
var AG_each = function(selector, fn) { if (!document.querySelectorAll) return; var elements = document.querySelectorAll(selector); for (var i = 0; i < elements.length; i++) { fn(elements[i]); }; };
} catch (ex) { console.error('Error executing AG js: ' + ex); }