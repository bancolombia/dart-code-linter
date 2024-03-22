"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[1341],{3905:(e,n,t)=>{t.d(n,{Zo:()=>d,kt:()=>g});var a=t(7294);function r(e,n,t){return n in e?Object.defineProperty(e,n,{value:t,enumerable:!0,configurable:!0,writable:!0}):e[n]=t,e}function o(e,n){var t=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);n&&(a=a.filter((function(n){return Object.getOwnPropertyDescriptor(e,n).enumerable}))),t.push.apply(t,a)}return t}function s(e){for(var n=1;n<arguments.length;n++){var t=null!=arguments[n]?arguments[n]:{};n%2?o(Object(t),!0).forEach((function(n){r(e,n,t[n])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(t)):o(Object(t)).forEach((function(n){Object.defineProperty(e,n,Object.getOwnPropertyDescriptor(t,n))}))}return e}function i(e,n){if(null==e)return{};var t,a,r=function(e,n){if(null==e)return{};var t,a,r={},o=Object.keys(e);for(a=0;a<o.length;a++)t=o[a],n.indexOf(t)>=0||(r[t]=e[t]);return r}(e,n);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(a=0;a<o.length;a++)t=o[a],n.indexOf(t)>=0||Object.prototype.propertyIsEnumerable.call(e,t)&&(r[t]=e[t])}return r}var l=a.createContext({}),c=function(e){var n=a.useContext(l),t=n;return e&&(t="function"==typeof e?e(n):s(s({},n),e)),t},d=function(e){var n=c(e.components);return a.createElement(l.Provider,{value:n},e.children)},m="mdxType",p={inlineCode:"code",wrapper:function(e){var n=e.children;return a.createElement(a.Fragment,{},n)}},u=a.forwardRef((function(e,n){var t=e.components,r=e.mdxType,o=e.originalType,l=e.parentName,d=i(e,["components","mdxType","originalType","parentName"]),m=c(t),u=r,g=m["".concat(l,".").concat(u)]||m[u]||p[u]||o;return t?a.createElement(g,s(s({ref:n},d),{},{components:t})):a.createElement(g,s({ref:n},d))}));function g(e,n){var t=arguments,r=n&&n.mdxType;if("string"==typeof e||r){var o=t.length,s=new Array(o);s[0]=u;var i={};for(var l in n)hasOwnProperty.call(n,l)&&(i[l]=n[l]);i.originalType=e,i[m]="string"==typeof e?e:r,s[1]=i;for(var c=2;c<o;c++)s[c]=t[c];return a.createElement.apply(null,s)}return a.createElement.apply(null,t)}u.displayName="MDXCreateElement"},2527:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>l,contentTitle:()=>s,default:()=>p,frontMatter:()=>o,metadata:()=>i,toc:()=>c});var a=t(7462),r=(t(7294),t(3905));const o={},s="ban-name",i={unversionedId:"rules/dart/ban-name",id:"rules/dart/ban-name",title:"ban-name",description:"added in: 1.6.0 warning",source:"@site/docs/rules/dart/ban-name.mdx",sourceDirName:"rules/dart",slug:"/rules/dart/ban-name",permalink:"/docs/rules/dart/ban-name",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/rules/dart/ban-name.mdx",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"avoid-unused-parameters",permalink:"/docs/rules/dart/avoid-unused-parameters"},next:{title:"binary-expression-operand-order",permalink:"/docs/rules/dart/binary-expression-operand-order"}},l={},c=[{value:"Example",id:"example",level:2},{value:"Bad:",id:"bad",level:3},{value:"Config example",id:"config-example",level:2}],d={toc:c},m="wrapper";function p(e){let{components:n,...t}=e;return(0,r.kt)(m,(0,a.Z)({},d,t,{components:n,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"ban-name"},"ban-name"),(0,r.kt)("p",null,"added in: 1.6.0 ",(0,r.kt)("span",{style:{color:"orange"}},"warning")),(0,r.kt)("p",null,"Configure some names that you want to ban."),(0,r.kt)("admonition",{type:"danger"},(0,r.kt)("p",{parentName:"admonition"},"This rule is deprecated. Use ",(0,r.kt)("a",{parentName:"p",href:"https://dcm.dev/docs/rules/common/banned-usage/"},"https://dcm.dev/docs/rules/common/banned-usage/")," instead.")),(0,r.kt)("h2",{id:"example"},"Example"),(0,r.kt)("h3",{id:"bad"},"Bad:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"// suppose the configuration is the one shown below\n\nshowDialog('some_arguments', 'another_argument'); // LINT\nmaterial.showDialog('some_arguments', 'another_argument'); // LINT\n\nvar strangeName = 42; // LINT\n\nvoid strangeName() {} // LINT\n\n// LINT\nclass AnotherStrangeName {\n  late var strangeName; // LINT\n}\n\nStrangeClass.someMethod(); // LINT\nNonStrangeClass.someMethod();\n\nDateTime.now(); // LINT\nDateTime.now().day; // LINT\nclass DateTimeTest {\n  final currentTimestamp = DateTime.now(); // LINT\n}\nDateTime currentTimestamp = DateTime('01.01.1959');\n")),(0,r.kt)("p",null,"\u2705 Good:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"myShowDialog();\nNonStrangeClass.someMethod();\nclock.now();\nclock.now().day;\nclass DateTimeTest {\n  final currentTimestamp = clock.now();\n}\n")),(0,r.kt)("h2",{id:"config-example"},"Config example"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-yaml"},"dart_code_linter:\n  ...\n  rules:\n    ...\n    - ban-name:\n        entries:\n        - ident: showDialog\n          description: Please use myShowDialog in this package\n        - ident: strangeName\n          description: The name is too strange\n        - ident: AnotherStrangeName\n          description: Oops\n        - ident: StrangeClass.someMethod\n          description: Please use a NonStrangeClass.someMethod instead\n        - ident: DateTime.now\n          description: Please use a clock.now instead\n")))}p.isMDXComponent=!0}}]);