"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[7224],{3905:(e,r,t)=>{t.d(r,{Zo:()=>d,kt:()=>y});var n=t(7294);function o(e,r,t){return r in e?Object.defineProperty(e,r,{value:t,enumerable:!0,configurable:!0,writable:!0}):e[r]=t,e}function a(e,r){var t=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);r&&(n=n.filter((function(r){return Object.getOwnPropertyDescriptor(e,r).enumerable}))),t.push.apply(t,n)}return t}function i(e){for(var r=1;r<arguments.length;r++){var t=null!=arguments[r]?arguments[r]:{};r%2?a(Object(t),!0).forEach((function(r){o(e,r,t[r])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(t)):a(Object(t)).forEach((function(r){Object.defineProperty(e,r,Object.getOwnPropertyDescriptor(t,r))}))}return e}function s(e,r){if(null==e)return{};var t,n,o=function(e,r){if(null==e)return{};var t,n,o={},a=Object.keys(e);for(n=0;n<a.length;n++)t=a[n],r.indexOf(t)>=0||(o[t]=e[t]);return o}(e,r);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)t=a[n],r.indexOf(t)>=0||Object.prototype.propertyIsEnumerable.call(e,t)&&(o[t]=e[t])}return o}var l=n.createContext({}),c=function(e){var r=n.useContext(l),t=r;return e&&(t="function"==typeof e?e(r):i(i({},r),e)),t},d=function(e){var r=c(e.components);return n.createElement(l.Provider,{value:r},e.children)},u="mdxType",p={inlineCode:"code",wrapper:function(e){var r=e.children;return n.createElement(n.Fragment,{},r)}},f=n.forwardRef((function(e,r){var t=e.components,o=e.mdxType,a=e.originalType,l=e.parentName,d=s(e,["components","mdxType","originalType","parentName"]),u=c(t),f=o,y=u["".concat(l,".").concat(f)]||u[f]||p[f]||a;return t?n.createElement(y,i(i({ref:r},d),{},{components:t})):n.createElement(y,i({ref:r},d))}));function y(e,r){var t=arguments,o=r&&r.mdxType;if("string"==typeof e||o){var a=t.length,i=new Array(a);i[0]=f;var s={};for(var l in r)hasOwnProperty.call(r,l)&&(s[l]=r[l]);s.originalType=e,s[u]="string"==typeof e?e:o,i[1]=s;for(var c=2;c<a;c++)i[c]=t[c];return n.createElement.apply(null,i)}return n.createElement.apply(null,t)}f.displayName="MDXCreateElement"},7087:(e,r,t)=>{t.r(r),t.d(r,{assets:()=>l,contentTitle:()=>i,default:()=>p,frontMatter:()=>a,metadata:()=>s,toc:()=>c});var n=t(7462),o=(t(7294),t(3905));const a={},i="avoid-unnecessary-conditionals",s={unversionedId:"rules/dart/avoid-unnecessary-conditionals",id:"rules/dart/avoid-unnecessary-conditionals",title:"avoid-unnecessary-conditionals",description:"added in: 1.6.0 warning",source:"@site/docs/rules/dart/avoid-unnecessary-conditionals.mdx",sourceDirName:"rules/dart",slug:"/rules/dart/avoid-unnecessary-conditionals",permalink:"/es/docs/rules/dart/avoid-unnecessary-conditionals",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/rules/dart/avoid-unnecessary-conditionals.mdx",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"avoid-top-level-members-in-tests",permalink:"/es/docs/rules/dart/avoid-top-level-members-in-tests"},next:{title:"avoid-unnecessary-type-assertions",permalink:"/es/docs/rules/dart/avoid-unnecessary-type-assertions"}},l={},c=[{value:"Example",id:"example",level:2},{value:"Bad:",id:"bad",level:3},{value:"Good:",id:"good",level:3}],d={toc:c},u="wrapper";function p(e){let{components:r,...t}=e;return(0,o.kt)(u,(0,n.Z)({},d,t,{components:r,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"avoid-unnecessary-conditionals"},"avoid-unnecessary-conditionals"),(0,o.kt)("p",null,"added in: 1.6.0 ",(0,o.kt)("span",{style:{color:"orange"}},"warning")),(0,o.kt)("p",null,"Checks for unnecessary conditional expressions."),(0,o.kt)("h2",{id:"example"},"Example"),(0,o.kt)("h3",{id:"bad"},"Bad:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-dart"},"bool baz() => foo ? true : false; // LINT\n\nbool bar() => foo ? false : true; // LINT\n")),(0,o.kt)("h3",{id:"good"},"Good:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-dart"},"bool baz() => foo;\n\nbool bar() => !foo;\n")))}p.isMDXComponent=!0}}]);