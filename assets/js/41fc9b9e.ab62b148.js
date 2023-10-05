"use strict";(self.webpackChunkdart_code_linter=self.webpackChunkdart_code_linter||[]).push([[6e3],{3905:(e,t,n)=>{n.d(t,{Zo:()=>s,kt:()=>f});var i=n(7294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function r(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);t&&(i=i.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,i)}return n}function c(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?r(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):r(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function a(e,t){if(null==e)return{};var n,i,o=function(e,t){if(null==e)return{};var n,i,o={},r=Object.keys(e);for(i=0;i<r.length;i++)n=r[i],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);for(i=0;i<r.length;i++)n=r[i],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var l=i.createContext({}),m=function(e){var t=i.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):c(c({},t),e)),n},s=function(e){var t=m(e.components);return i.createElement(l.Provider,{value:t},e.children)},d="mdxType",p={inlineCode:"code",wrapper:function(e){var t=e.children;return i.createElement(i.Fragment,{},t)}},u=i.forwardRef((function(e,t){var n=e.components,o=e.mdxType,r=e.originalType,l=e.parentName,s=a(e,["components","mdxType","originalType","parentName"]),d=m(n),u=o,f=d["".concat(l,".").concat(u)]||d[u]||p[u]||r;return n?i.createElement(f,c(c({ref:t},s),{},{components:n})):i.createElement(f,c({ref:t},s))}));function f(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var r=n.length,c=new Array(r);c[0]=u;var a={};for(var l in t)hasOwnProperty.call(t,l)&&(a[l]=t[l]);a.originalType=e,a[d]="string"==typeof e?e:o,c[1]=a;for(var m=2;m<r;m++)c[m]=n[m];return i.createElement.apply(null,c)}return i.createElement.apply(null,n)}u.displayName="MDXCreateElement"},3612:(e,t,n)=>{n.d(t,{Z:()=>d});var i=n(7294),o=n(6010),r=n(5281),c=n(5999);const a={admonition:"admonition_LlT9",admonitionHeading:"admonitionHeading_tbUL",admonitionIcon:"admonitionIcon_kALy",admonitionContent:"admonitionContent_S0QG"};const l={note:{infimaClassName:"secondary",iconComponent:function(){return i.createElement("svg",{viewBox:"0 0 14 16"},i.createElement("path",{fillRule:"evenodd",d:"M6.3 5.69a.942.942 0 0 1-.28-.7c0-.28.09-.52.28-.7.19-.18.42-.28.7-.28.28 0 .52.09.7.28.18.19.28.42.28.7 0 .28-.09.52-.28.7a1 1 0 0 1-.7.3c-.28 0-.52-.11-.7-.3zM8 7.99c-.02-.25-.11-.48-.31-.69-.2-.19-.42-.3-.69-.31H6c-.27.02-.48.13-.69.31-.2.2-.3.44-.31.69h1v3c.02.27.11.5.31.69.2.2.42.31.69.31h1c.27 0 .48-.11.69-.31.2-.19.3-.42.31-.69H8V7.98v.01zM7 2.3c-3.14 0-5.7 2.54-5.7 5.68 0 3.14 2.56 5.7 5.7 5.7s5.7-2.55 5.7-5.7c0-3.15-2.56-5.69-5.7-5.69v.01zM7 .98c3.86 0 7 3.14 7 7s-3.14 7-7 7-7-3.12-7-7 3.14-7 7-7z"}))},label:i.createElement(c.Z,{id:"theme.admonition.note",description:"The default label used for the Note admonition (:::note)"},"note")},tip:{infimaClassName:"success",iconComponent:function(){return i.createElement("svg",{viewBox:"0 0 12 16"},i.createElement("path",{fillRule:"evenodd",d:"M6.5 0C3.48 0 1 2.19 1 5c0 .92.55 2.25 1 3 1.34 2.25 1.78 2.78 2 4v1h5v-1c.22-1.22.66-1.75 2-4 .45-.75 1-2.08 1-3 0-2.81-2.48-5-5.5-5zm3.64 7.48c-.25.44-.47.8-.67 1.11-.86 1.41-1.25 2.06-1.45 3.23-.02.05-.02.11-.02.17H5c0-.06 0-.13-.02-.17-.2-1.17-.59-1.83-1.45-3.23-.2-.31-.42-.67-.67-1.11C2.44 6.78 2 5.65 2 5c0-2.2 2.02-4 4.5-4 1.22 0 2.36.42 3.22 1.19C10.55 2.94 11 3.94 11 5c0 .66-.44 1.78-.86 2.48zM4 14h5c-.23 1.14-1.3 2-2.5 2s-2.27-.86-2.5-2z"}))},label:i.createElement(c.Z,{id:"theme.admonition.tip",description:"The default label used for the Tip admonition (:::tip)"},"tip")},danger:{infimaClassName:"danger",iconComponent:function(){return i.createElement("svg",{viewBox:"0 0 12 16"},i.createElement("path",{fillRule:"evenodd",d:"M5.05.31c.81 2.17.41 3.38-.52 4.31C3.55 5.67 1.98 6.45.9 7.98c-1.45 2.05-1.7 6.53 3.53 7.7-2.2-1.16-2.67-4.52-.3-6.61-.61 2.03.53 3.33 1.94 2.86 1.39-.47 2.3.53 2.27 1.67-.02.78-.31 1.44-1.13 1.81 3.42-.59 4.78-3.42 4.78-5.56 0-2.84-2.53-3.22-1.25-5.61-1.52.13-2.03 1.13-1.89 2.75.09 1.08-1.02 1.8-1.86 1.33-.67-.41-.66-1.19-.06-1.78C8.18 5.31 8.68 2.45 5.05.32L5.03.3l.02.01z"}))},label:i.createElement(c.Z,{id:"theme.admonition.danger",description:"The default label used for the Danger admonition (:::danger)"},"danger")},info:{infimaClassName:"info",iconComponent:function(){return i.createElement("svg",{viewBox:"0 0 14 16"},i.createElement("path",{fillRule:"evenodd",d:"M7 2.3c3.14 0 5.7 2.56 5.7 5.7s-2.56 5.7-5.7 5.7A5.71 5.71 0 0 1 1.3 8c0-3.14 2.56-5.7 5.7-5.7zM7 1C3.14 1 0 4.14 0 8s3.14 7 7 7 7-3.14 7-7-3.14-7-7-7zm1 3H6v5h2V4zm0 6H6v2h2v-2z"}))},label:i.createElement(c.Z,{id:"theme.admonition.info",description:"The default label used for the Info admonition (:::info)"},"info")},caution:{infimaClassName:"warning",iconComponent:function(){return i.createElement("svg",{viewBox:"0 0 16 16"},i.createElement("path",{fillRule:"evenodd",d:"M8.893 1.5c-.183-.31-.52-.5-.887-.5s-.703.19-.886.5L.138 13.499a.98.98 0 0 0 0 1.001c.193.31.53.501.886.501h13.964c.367 0 .704-.19.877-.5a1.03 1.03 0 0 0 .01-1.002L8.893 1.5zm.133 11.497H6.987v-2.003h2.039v2.003zm0-3.004H6.987V5.987h2.039v4.006z"}))},label:i.createElement(c.Z,{id:"theme.admonition.caution",description:"The default label used for the Caution admonition (:::caution)"},"caution")}},m={secondary:"note",important:"info",success:"tip",warning:"danger"};function s(e){const{mdxAdmonitionTitle:t,rest:n}=function(e){const t=i.Children.toArray(e),n=t.find((e=>i.isValidElement(e)&&"mdxAdmonitionTitle"===e.props?.mdxType)),o=i.createElement(i.Fragment,null,t.filter((e=>e!==n)));return{mdxAdmonitionTitle:n,rest:o}}(e.children);return{...e,title:e.title??t,children:n}}function d(e){const{children:t,type:n,title:c,icon:d}=s(e),p=function(e){const t=m[e]??e,n=l[t];return n||(console.warn(`No admonition config found for admonition type "${t}". Using Info as fallback.`),l.info)}(n),u=c??p.label,{iconComponent:f}=p,h=d??i.createElement(f,null);return i.createElement("div",{className:(0,o.Z)(r.k.common.admonition,r.k.common.admonitionType(e.type),"alert",`alert--${p.infimaClassName}`,a.admonition)},i.createElement("div",{className:a.admonitionHeading},i.createElement("span",{className:a.admonitionIcon},h),u),i.createElement("div",{className:a.admonitionContent},t))}},4354:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>m,contentTitle:()=>a,default:()=>u,frontMatter:()=>c,metadata:()=>l,toc:()=>s});var i=n(7462),o=(n(7294),n(3905)),r=n(3612);const c={sidebar_position:6},a="Metrics",l={unversionedId:"metrics/metrics",id:"metrics/metrics",title:"Metrics",description:"Metrics configuration is described here.",source:"@site/docs/metrics/metrics.mdx",sourceDirName:"metrics",slug:"/metrics/",permalink:"/docs/metrics/",draft:!1,editUrl:"https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source/docs/metrics/metrics.mdx",tags:[],version:"current",sidebarPosition:6,frontMatter:{sidebar_position:6},sidebar:"tutorialSidebar",previous:{title:"prefer-provide-intl-description",permalink:"/docs/rules/intl/prefer-provide-intl-description"},next:{title:"cyclomatic-complexity",permalink:"/docs/metrics/cyclomatic-complexity"}},m={},s=[{value:"Function specific metrics",id:"function-specific-metrics",level:3},{value:"Class specific metrics",id:"class-specific-metrics",level:2},{value:"File specific metrics",id:"file-specific-metrics",level:2}],d={toc:s},p="wrapper";function u(e){let{components:t,...n}=e;return(0,o.kt)(p,(0,i.Z)({},d,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"metrics"},"Metrics"),(0,o.kt)("admonition",{type:"tip"},(0,o.kt)("p",{parentName:"admonition"},"Metrics configuration is ",(0,o.kt)("a",{parentName:"p",href:"../configuration/configuring-metrics"},"described here"),".")),(0,o.kt)("p",null,"Metrics are grouped by a category to help you understand their purpose."),(0,o.kt)("h3",{id:"function-specific-metrics"},"Function specific metrics"),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"cyclomatic-complexity",mdxType:"Admonition"},(0,o.kt)("p",null,"The number of linearly-independent paths through a method.")),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"halstead-volume\n",mdxType:"Admonition"},(0,o.kt)("p",null,(0,o.kt)("p",null,"The method size, based on the numbers of operators and operands."))),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"lines-of-code",mdxType:"Admonition"},(0,o.kt)("p",null,(0,o.kt)("p",null,"The number of physical lines of code of a method, including blank lines and comments."))),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"maintainability-index",mdxType:"Admonition"},(0,o.kt)("p",null,"The indicator which mean how maintainable the source code is.")),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"maximum-nesting-level\n",mdxType:"Admonition"},(0,o.kt)("p",null,"The maximum nesting level of control structures within a method.")),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"number-of-parameters\n",mdxType:"Admonition"},(0,o.kt)("p",null,"The number of parameters received by a method.")),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"source-lines-of-code",mdxType:"Admonition"},(0,o.kt)("p",null,"The approximate number of source code lines in a method, blank lines and comments are not counted.")),(0,o.kt)("h2",{id:"class-specific-metrics"},"Class specific metrics"),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"number-of-methods",mdxType:"Admonition"},(0,o.kt)("p",null,(0,o.kt)("p",null,"The number of methods of a class."))),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"weight-of-class",mdxType:"Admonition"},(0,o.kt)("p",null,'The number of "functional" public methods divided by the total number of public members.')),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"source-lines-of-code",mdxType:"Admonition"},(0,o.kt)("p",null,"The approximate number of source code lines in a method, blank lines and comments are not counted.")),(0,o.kt)("h2",{id:"file-specific-metrics"},"File specific metrics"),(0,o.kt)(r.Z,{type:"info",icon:"-",title:"technical-debt",mdxType:"Admonition"},(0,o.kt)("p",null,"The cost of additional rework caused by choosing an easy (limited) solution now instead of using a better approach that would take longer.")))}u.isMDXComponent=!0}}]);