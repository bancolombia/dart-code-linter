"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[7813],{3905:(e,t,n)=>{n.d(t,{Zo:()=>m,kt:()=>f});var a=n(7294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function l(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?l(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):l(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function o(e,t){if(null==e)return{};var n,a,r=function(e,t){if(null==e)return{};var n,a,r={},l=Object.keys(e);for(a=0;a<l.length;a++)n=l[a],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(a=0;a<l.length;a++)n=l[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var c=a.createContext({}),d=function(e){var t=a.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},m=function(e){var t=d(e.components);return a.createElement(c.Provider,{value:t},e.children)},s="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},p=a.forwardRef((function(e,t){var n=e.components,r=e.mdxType,l=e.originalType,c=e.parentName,m=o(e,["components","mdxType","originalType","parentName"]),s=d(n),p=r,f=s["".concat(c,".").concat(p)]||s[p]||u[p]||l;return n?a.createElement(f,i(i({ref:t},m),{},{components:n})):a.createElement(f,i({ref:t},m))}));function f(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var l=n.length,i=new Array(l);i[0]=p;var o={};for(var c in t)hasOwnProperty.call(t,c)&&(o[c]=t[c]);o.originalType=e,o[s]="string"==typeof e?e:r,i[1]=o;for(var d=2;d<l;d++)i[d]=n[d];return a.createElement.apply(null,i)}return a.createElement.apply(null,n)}p.displayName="MDXCreateElement"},3612:(e,t,n)=>{n.d(t,{Z:()=>s});var a=n(7294),r=n(6010),l=n(5281),i=n(5999);const o={admonition:"admonition_LlT9",admonitionHeading:"admonitionHeading_tbUL",admonitionIcon:"admonitionIcon_kALy",admonitionContent:"admonitionContent_S0QG"};const c={note:{infimaClassName:"secondary",iconComponent:function(){return a.createElement("svg",{viewBox:"0 0 14 16"},a.createElement("path",{fillRule:"evenodd",d:"M6.3 5.69a.942.942 0 0 1-.28-.7c0-.28.09-.52.28-.7.19-.18.42-.28.7-.28.28 0 .52.09.7.28.18.19.28.42.28.7 0 .28-.09.52-.28.7a1 1 0 0 1-.7.3c-.28 0-.52-.11-.7-.3zM8 7.99c-.02-.25-.11-.48-.31-.69-.2-.19-.42-.3-.69-.31H6c-.27.02-.48.13-.69.31-.2.2-.3.44-.31.69h1v3c.02.27.11.5.31.69.2.2.42.31.69.31h1c.27 0 .48-.11.69-.31.2-.19.3-.42.31-.69H8V7.98v.01zM7 2.3c-3.14 0-5.7 2.54-5.7 5.68 0 3.14 2.56 5.7 5.7 5.7s5.7-2.55 5.7-5.7c0-3.15-2.56-5.69-5.7-5.69v.01zM7 .98c3.86 0 7 3.14 7 7s-3.14 7-7 7-7-3.12-7-7 3.14-7 7-7z"}))},label:a.createElement(i.Z,{id:"theme.admonition.note",description:"The default label used for the Note admonition (:::note)"},"note")},tip:{infimaClassName:"success",iconComponent:function(){return a.createElement("svg",{viewBox:"0 0 12 16"},a.createElement("path",{fillRule:"evenodd",d:"M6.5 0C3.48 0 1 2.19 1 5c0 .92.55 2.25 1 3 1.34 2.25 1.78 2.78 2 4v1h5v-1c.22-1.22.66-1.75 2-4 .45-.75 1-2.08 1-3 0-2.81-2.48-5-5.5-5zm3.64 7.48c-.25.44-.47.8-.67 1.11-.86 1.41-1.25 2.06-1.45 3.23-.02.05-.02.11-.02.17H5c0-.06 0-.13-.02-.17-.2-1.17-.59-1.83-1.45-3.23-.2-.31-.42-.67-.67-1.11C2.44 6.78 2 5.65 2 5c0-2.2 2.02-4 4.5-4 1.22 0 2.36.42 3.22 1.19C10.55 2.94 11 3.94 11 5c0 .66-.44 1.78-.86 2.48zM4 14h5c-.23 1.14-1.3 2-2.5 2s-2.27-.86-2.5-2z"}))},label:a.createElement(i.Z,{id:"theme.admonition.tip",description:"The default label used for the Tip admonition (:::tip)"},"tip")},danger:{infimaClassName:"danger",iconComponent:function(){return a.createElement("svg",{viewBox:"0 0 12 16"},a.createElement("path",{fillRule:"evenodd",d:"M5.05.31c.81 2.17.41 3.38-.52 4.31C3.55 5.67 1.98 6.45.9 7.98c-1.45 2.05-1.7 6.53 3.53 7.7-2.2-1.16-2.67-4.52-.3-6.61-.61 2.03.53 3.33 1.94 2.86 1.39-.47 2.3.53 2.27 1.67-.02.78-.31 1.44-1.13 1.81 3.42-.59 4.78-3.42 4.78-5.56 0-2.84-2.53-3.22-1.25-5.61-1.52.13-2.03 1.13-1.89 2.75.09 1.08-1.02 1.8-1.86 1.33-.67-.41-.66-1.19-.06-1.78C8.18 5.31 8.68 2.45 5.05.32L5.03.3l.02.01z"}))},label:a.createElement(i.Z,{id:"theme.admonition.danger",description:"The default label used for the Danger admonition (:::danger)"},"danger")},info:{infimaClassName:"info",iconComponent:function(){return a.createElement("svg",{viewBox:"0 0 14 16"},a.createElement("path",{fillRule:"evenodd",d:"M7 2.3c3.14 0 5.7 2.56 5.7 5.7s-2.56 5.7-5.7 5.7A5.71 5.71 0 0 1 1.3 8c0-3.14 2.56-5.7 5.7-5.7zM7 1C3.14 1 0 4.14 0 8s3.14 7 7 7 7-3.14 7-7-3.14-7-7-7zm1 3H6v5h2V4zm0 6H6v2h2v-2z"}))},label:a.createElement(i.Z,{id:"theme.admonition.info",description:"The default label used for the Info admonition (:::info)"},"info")},caution:{infimaClassName:"warning",iconComponent:function(){return a.createElement("svg",{viewBox:"0 0 16 16"},a.createElement("path",{fillRule:"evenodd",d:"M8.893 1.5c-.183-.31-.52-.5-.887-.5s-.703.19-.886.5L.138 13.499a.98.98 0 0 0 0 1.001c.193.31.53.501.886.501h13.964c.367 0 .704-.19.877-.5a1.03 1.03 0 0 0 .01-1.002L8.893 1.5zm.133 11.497H6.987v-2.003h2.039v2.003zm0-3.004H6.987V5.987h2.039v4.006z"}))},label:a.createElement(i.Z,{id:"theme.admonition.caution",description:"The default label used for the Caution admonition (:::caution)"},"caution")}},d={secondary:"note",important:"info",success:"tip",warning:"danger"};function m(e){const{mdxAdmonitionTitle:t,rest:n}=function(e){const t=a.Children.toArray(e),n=t.find((e=>a.isValidElement(e)&&"mdxAdmonitionTitle"===e.props?.mdxType)),r=a.createElement(a.Fragment,null,t.filter((e=>e!==n)));return{mdxAdmonitionTitle:n,rest:r}}(e.children);return{...e,title:e.title??t,children:n}}function s(e){const{children:t,type:n,title:i,icon:s}=m(e),u=function(e){const t=d[e]??e,n=c[t];return n||(console.warn(`No admonition config found for admonition type "${t}". Using Info as fallback.`),c.info)}(n),p=i??u.label,{iconComponent:f}=u,k=s??a.createElement(f,null);return a.createElement("div",{className:(0,r.Z)(l.k.common.admonition,l.k.common.admonitionType(e.type),"alert",`alert--${u.infimaClassName}`,o.admonition)},a.createElement("div",{className:o.admonitionHeading},a.createElement("span",{className:o.admonitionIcon},k),p),a.createElement("div",{className:o.admonitionContent},t))}},3279:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>d,contentTitle:()=>o,default:()=>p,frontMatter:()=>i,metadata:()=>c,toc:()=>m});var a=n(7462),r=(n(7294),n(3905)),l=n(3612);const i={sidebar_position:4,title:"CLI"},o="Command Line Interface",c={unversionedId:"cli/cli",id:"cli/cli",title:"CLI",description:"To use the package as a command-line tool, run:",source:"@site/docs/cli/cli.md",sourceDirName:"cli",slug:"/cli/",permalink:"/es/docs/cli/",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/cli/cli.md",tags:[],version:"current",sidebarPosition:4,frontMatter:{sidebar_position:4,title:"CLI"},sidebar:"tutorialSidebar",previous:{title:"Presets",permalink:"/es/docs/configuration/presets"},next:{title:"analyze",permalink:"/es/docs/cli/analyze"}},d={},m=[{value:"Available commands",id:"available-commands",level:2}],s={toc:m},u="wrapper";function p(e){let{components:t,...n}=e;return(0,r.kt)(u,(0,a.Z)({},s,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"command-line-interface"},"Command Line Interface"),(0,r.kt)("p",null,"To use the package as a command-line tool, run:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"$ flutter pub run dart_code_linter:metrics <command> lib\n")),(0,r.kt)("p",null,"Alternatively, the package can be installed globally:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"$ flutter pub global activate dart_code_linter\n$ metrics <command> lib\n")),(0,r.kt)("p",null,"It will produce a result in one of the supported formats:"),(0,r.kt)("ul",null,(0,r.kt)("li",{parentName:"ul"},"Console"),(0,r.kt)("li",{parentName:"ul"},"GitHub"),(0,r.kt)("li",{parentName:"ul"},"Checkstyle"),(0,r.kt)("li",{parentName:"ul"},"Codeclimate"),(0,r.kt)("li",{parentName:"ul"},"HTML"),(0,r.kt)("li",{parentName:"ul"},"JSON")),(0,r.kt)(l.Z,{type:"info",icon:"-",title:"INFO",mdxType:"Admonition"},(0,r.kt)("p",null,"You need to configure rules entry in the analysis_options.yaml to have rules report included into the result.")),(0,r.kt)("h2",{id:"available-commands"},"Available commands"),(0,r.kt)("table",null,(0,r.kt)("thead",{parentName:"table"},(0,r.kt)("tr",{parentName:"thead"},(0,r.kt)("th",{parentName:"tr",align:null},"Command"),(0,r.kt)("th",{parentName:"tr",align:null},"Example of use"),(0,r.kt)("th",{parentName:"tr",align:null},"Short description"))),(0,r.kt)("tbody",{parentName:"table"},(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"analyze"),(0,r.kt)("td",{parentName:"tr",align:null},"dart run dart_code_linter:metrics analyze lib"),(0,r.kt)("td",{parentName:"tr",align:null},"Reports code metrics, rules and anti-patterns violations.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"check-unnecessary-nullable"),(0,r.kt)("td",{parentName:"tr",align:null},"dart run dart_code_linter:metrics check-unnecessary-nullable lib"),(0,r.kt)("td",{parentName:"tr",align:null},"Checks unnecessary nullable parameters.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"check-unused-files"),(0,r.kt)("td",{parentName:"tr",align:null},"dart run dart_code_linter:metrics check-unused-files lib"),(0,r.kt)("td",{parentName:"tr",align:null},"Checks unused *.dart files.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"check-unused-l10n"),(0,r.kt)("td",{parentName:"tr",align:null},"dart run dart_code_linter:metrics check-unused-l10n lib"),(0,r.kt)("td",{parentName:"tr",align:null},"Checks unused localization in *.dart files.")),(0,r.kt)("tr",{parentName:"tbody"},(0,r.kt)("td",{parentName:"tr",align:null},"check-unused-code"),(0,r.kt)("td",{parentName:"tr",align:null},"dart run dart_code_linter:metrics check-unused-code lib"),(0,r.kt)("td",{parentName:"tr",align:null},"Checks unused code in *.dart files.")))),(0,r.kt)("p",null,"For additional help on any of the commands:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"$ flutter pub run dart_code_linter:metrics --help <command>\n")),(0,r.kt)("h1",{id:"multi-package-repositories-usage"},"Multi-package repositories usage"),(0,r.kt)("p",null,"If you run a command from the root of a multi-package repository (a.k.a. monorepo), it'll pick up analysis_options.yaml files correctly."),(0,r.kt)("p",null,"Additionally, if you use Melos, you can add custom command to the melos.yaml."))}p.isMDXComponent=!0}}]);