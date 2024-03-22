"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[767],{3905:(e,t,r)=>{r.d(t,{Zo:()=>c,kt:()=>m});var n=r(7294);function a(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function l(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function o(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?l(Object(r),!0).forEach((function(t){a(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):l(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function i(e,t){if(null==e)return{};var r,n,a=function(e,t){if(null==e)return{};var r,n,a={},l=Object.keys(e);for(n=0;n<l.length;n++)r=l[n],t.indexOf(r)>=0||(a[r]=e[r]);return a}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(n=0;n<l.length;n++)r=l[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(a[r]=e[r])}return a}var s=n.createContext({}),p=function(e){var t=n.useContext(s),r=t;return e&&(r="function"==typeof e?e(t):o(o({},t),e)),r},c=function(e){var t=p(e.components);return n.createElement(s.Provider,{value:t},e.children)},d="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},f=n.forwardRef((function(e,t){var r=e.components,a=e.mdxType,l=e.originalType,s=e.parentName,c=i(e,["components","mdxType","originalType","parentName"]),d=p(r),f=a,m=d["".concat(s,".").concat(f)]||d[f]||u[f]||l;return r?n.createElement(m,o(o({ref:t},c),{},{components:r})):n.createElement(m,o({ref:t},c))}));function m(e,t){var r=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var l=r.length,o=new Array(l);o[0]=f;var i={};for(var s in t)hasOwnProperty.call(t,s)&&(i[s]=t[s]);i.originalType=e,i[d]="string"==typeof e?e:a,o[1]=i;for(var p=2;p<l;p++)o[p]=r[p];return n.createElement.apply(null,o)}return n.createElement.apply(null,r)}f.displayName="MDXCreateElement"},7480:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>s,contentTitle:()=>o,default:()=>u,frontMatter:()=>l,metadata:()=>i,toc:()=>p});var n=r(7462),a=(r(7294),r(3905));const l={},o="prefer-last",i={unversionedId:"rules/dart/prefer-last",id:"rules/dart/prefer-last",title:"prefer-last",description:"added in: 1.6.0 style",source:"@site/docs/rules/dart/prefer-last.mdx",sourceDirName:"rules/dart",slug:"/rules/dart/prefer-last",permalink:"/es/docs/rules/dart/prefer-last",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/rules/dart/prefer-last.mdx",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"prefer-iterable-of",permalink:"/es/docs/rules/dart/prefer-iterable-of"},next:{title:"prefer-match-file-name",permalink:"/es/docs/rules/dart/prefer-match-file-name"}},s={},p=[{value:"Example",id:"example",level:2},{value:"Bad:",id:"bad",level:3},{value:"Good:",id:"good",level:3}],c={toc:p},d="wrapper";function u(e){let{components:t,...r}=e;return(0,a.kt)(d,(0,n.Z)({},c,r,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"prefer-last"},"prefer-last"),(0,a.kt)("p",null,"added in: 1.6.0 ",(0,a.kt)("span",{style:{color:"green"}},"style")),(0,a.kt)("p",null,"Warns when the last element of an Iterable is accessed by ",(0,a.kt)("inlineCode",{parentName:"p"},"iterable[iterable.length - 1]")," or ",(0,a.kt)("inlineCode",{parentName:"p"},"iterable.elementAt(iterable.length - 1)")," instead of calling ",(0,a.kt)("inlineCode",{parentName:"p"},"iterable.last"),"."),(0,a.kt)("h2",{id:"example"},"Example"),(0,a.kt)("h3",{id:"bad"},"Bad:"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-dart"},"...\nconst list = [1, 2, 3, 4, 5, 6, 7, 8, 9];\n\nlist.elementAt(list.length - 1); // LINT\nlist[list.length - 1]; // LINT\n")),(0,a.kt)("h3",{id:"good"},"Good:"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-dart"},"const list = [1, 2, 3, 4, 5, 6, 7, 8, 9];\n\nlist.last;\n")))}u.isMDXComponent=!0}}]);