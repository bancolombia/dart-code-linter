"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[1053],{3905:(e,t,r)=>{r.d(t,{Zo:()=>p,kt:()=>f});var n=r(7294);function i(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function l(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function a(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?l(Object(r),!0).forEach((function(t){i(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):l(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function o(e,t){if(null==e)return{};var r,n,i=function(e,t){if(null==e)return{};var r,n,i={},l=Object.keys(e);for(n=0;n<l.length;n++)r=l[n],t.indexOf(r)>=0||(i[r]=e[r]);return i}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(n=0;n<l.length;n++)r=l[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(i[r]=e[r])}return i}var s=n.createContext({}),d=function(e){var t=n.useContext(s),r=t;return e&&(r="function"==typeof e?e(t):a(a({},t),e)),r},p=function(e){var t=d(e.components);return n.createElement(s.Provider,{value:t},e.children)},u="mdxType",c={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},g=n.forwardRef((function(e,t){var r=e.components,i=e.mdxType,l=e.originalType,s=e.parentName,p=o(e,["components","mdxType","originalType","parentName"]),u=d(r),g=i,f=u["".concat(s,".").concat(g)]||u[g]||c[g]||l;return r?n.createElement(f,a(a({ref:t},p),{},{components:r})):n.createElement(f,a({ref:t},p))}));function f(e,t){var r=arguments,i=t&&t.mdxType;if("string"==typeof e||i){var l=r.length,a=new Array(l);a[0]=g;var o={};for(var s in t)hasOwnProperty.call(t,s)&&(o[s]=t[s]);o.originalType=e,o[u]="string"==typeof e?e:i,a[1]=o;for(var d=2;d<l;d++)a[d]=r[d];return n.createElement.apply(null,a)}return n.createElement.apply(null,r)}g.displayName="MDXCreateElement"},4139:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>s,contentTitle:()=>a,default:()=>c,frontMatter:()=>l,metadata:()=>o,toc:()=>d});var n=r(7462),i=(r(7294),r(3905));const l={},a="prefer-single-widget-per-file",o={unversionedId:"rules/flutter/prefer-single-widget-per-file",id:"rules/flutter/prefer-single-widget-per-file",title:"prefer-single-widget-per-file",description:"added in: 1.6.0 style",source:"@site/docs/rules/flutter/prefer-single-widget-per-file.mdx",sourceDirName:"rules/flutter",slug:"/rules/flutter/prefer-single-widget-per-file",permalink:"/docs/rules/flutter/prefer-single-widget-per-file",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/rules/flutter/prefer-single-widget-per-file.mdx",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"prefer-extracting-callbacks",permalink:"/docs/rules/flutter/prefer-extracting-callbacks"},next:{title:"prefer-using-list-view",permalink:"/docs/rules/flutter/prefer-using-list-view"}},s={},d=[{value:"Config",id:"config",level:2},{value:"Example",id:"example",level:2},{value:"Bad:",id:"bad",level:3},{value:"Good:",id:"good",level:3}],p={toc:d},u="wrapper";function c(e){let{components:t,...r}=e;return(0,i.kt)(u,(0,n.Z)({},p,r,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("h1",{id:"prefer-single-widget-per-file"},"prefer-single-widget-per-file"),(0,i.kt)("p",null,"added in: 1.6.0 ",(0,i.kt)("span",{style:{color:"green"}},"style")),(0,i.kt)("p",null,"Warns when a file contains more than a single widget."),(0,i.kt)("p",null,"Ensures that files have a single responsibility so that each widget exists in its own file."),(0,i.kt)("h2",{id:"config"},"Config"),(0,i.kt)("p",null,"Set ",(0,i.kt)("inlineCode",{parentName:"p"},"ignore-private-widgets")," (default is ",(0,i.kt)("inlineCode",{parentName:"p"},"false"),") to ignore private widgets."),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-yaml"},"dart_code_linter:\n  ...\n  rules:\n    ...\n    - prefer-single-widget-per-file:\n        ignore-private-widgets: true\n")),(0,i.kt)("h2",{id:"example"},"Example"),(0,i.kt)("h3",{id:"bad"},"Bad:"),(0,i.kt)("p",null,"some_widgets.dart"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-dart"},"class SomeWidget extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    ...\n  }\n}\n\n// LINT\nclass SomeOtherWidget extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    ...\n  }\n}\n\n// LINT\nclass _SomeOtherWidget extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    ...\n  }\n}\n\n// LINT\nclass SomeStatefulWidget extends StatefulWidget {\n  @override\n  _SomeStatefulWidgetState createState() => _someStatefulWidgetState();\n}\n\nclass _SomeStatefulWidgetState extends State<InspirationCard> {\n  @override\n  Widget build(BuildContext context) {\n    ...\n  }\n}\n")),(0,i.kt)("h3",{id:"good"},"Good:"),(0,i.kt)("p",null,"some_widget.dart"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-dart"},"class SomeWidget extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    ...\n  }\n}\n")),(0,i.kt)("p",null,"some_other_widget.dart"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-dart"},"class SomeOtherWidget extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    ...\n  }\n}\n")))}c.isMDXComponent=!0}}]);