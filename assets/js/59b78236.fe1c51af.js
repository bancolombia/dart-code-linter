"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[2377],{3905:(e,t,r)=>{r.d(t,{Zo:()=>p,kt:()=>f});var a=r(7294);function o(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function n(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,a)}return r}function l(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?n(Object(r),!0).forEach((function(t){o(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):n(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function i(e,t){if(null==e)return{};var r,a,o=function(e,t){if(null==e)return{};var r,a,o={},n=Object.keys(e);for(a=0;a<n.length;a++)r=n[a],t.indexOf(r)>=0||(o[r]=e[r]);return o}(e,t);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);for(a=0;a<n.length;a++)r=n[a],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(o[r]=e[r])}return o}var d=a.createContext({}),s=function(e){var t=a.useContext(d),r=t;return e&&(r="function"==typeof e?e(t):l(l({},t),e)),r},p=function(e){var t=s(e.components);return a.createElement(d.Provider,{value:t},e.children)},u="mdxType",c={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},m=a.forwardRef((function(e,t){var r=e.components,o=e.mdxType,n=e.originalType,d=e.parentName,p=i(e,["components","mdxType","originalType","parentName"]),u=s(r),m=o,f=u["".concat(d,".").concat(m)]||u[m]||c[m]||n;return r?a.createElement(f,l(l({ref:t},p),{},{components:r})):a.createElement(f,l({ref:t},p))}));function f(e,t){var r=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var n=r.length,l=new Array(n);l[0]=m;var i={};for(var d in t)hasOwnProperty.call(t,d)&&(i[d]=t[d]);i.originalType=e,i[u]="string"==typeof e?e:o,l[1]=i;for(var s=2;s<n;s++)l[s]=r[s];return a.createElement.apply(null,l)}return a.createElement.apply(null,r)}m.displayName="MDXCreateElement"},1251:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>d,contentTitle:()=>l,default:()=>c,frontMatter:()=>n,metadata:()=>i,toc:()=>s});var a=r(7462),o=(r(7294),r(3905));const n={},l="avoid-double-slash-imports",i={unversionedId:"rules/dart/avoid-double-slash-imports",id:"rules/dart/avoid-double-slash-imports",title:"avoid-double-slash-imports",description:"added in: 1.6.0 warning",source:"@site/docs/rules/dart/avoid-double-slash-imports.mdx",sourceDirName:"rules/dart",slug:"/rules/dart/avoid-double-slash-imports",permalink:"/docs/rules/dart/avoid-double-slash-imports",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/rules/dart/avoid-double-slash-imports.mdx",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"avoid-collection-methods-with-unrelated-types",permalink:"/docs/rules/dart/avoid-collection-methods-with-unrelated-types"},next:{title:"avoid-duplicate-exports",permalink:"/docs/rules/dart/avoid-duplicate-exports"}},d={},s=[{value:"Example",id:"example",level:2},{value:"Bad:",id:"bad",level:3},{value:"Good:",id:"good",level:3}],p={toc:s},u="wrapper";function c(e){let{components:t,...r}=e;return(0,o.kt)(u,(0,a.Z)({},p,r,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"avoid-double-slash-imports"},"avoid-double-slash-imports"),(0,o.kt)("p",null,"added in: 1.6.0 ",(0,o.kt)("span",{style:{color:"orange"}},"warning")),(0,o.kt)("p",null,"Warns when an import/export directive contains a double slash."),(0,o.kt)("p",null,"Double slash in the URI is considered valid, but under some circumstances the program won't run."),(0,o.kt)("p",null,"See:"),(0,o.kt)("ul",null,(0,o.kt)("li",{parentName:"ul"},(0,o.kt)("a",{parentName:"li",href:"https://github.com/dart-lang/sdk/issues/36337"},"https://github.com/dart-lang/sdk/issues/36337"))),(0,o.kt)("h2",{id:"example"},"Example"),(0,o.kt)("h3",{id:"bad"},"Bad:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:test//material.dart'; // LINT\nimport 'package:mocktail/good_file.dart';\nimport '../../..//rule_utils_test.dart'; // LINT\n\nexport 'package:mocktail//good_file.dart'; // LINT\n\npart '../../..//individual/rules/empty.dart'; // LINT\n")),(0,o.kt)("h3",{id:"good"},"Good:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:test/material.dart';\nimport 'package:mocktail/good_file.dart';\nimport '../../../rule_utils_test.dart';\n\nexport 'package:mocktail/good_file.dart';\n\npart '../../../individual/rules/empty.dart';\n")))}c.isMDXComponent=!0}}]);