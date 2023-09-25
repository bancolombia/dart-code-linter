// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Dart Code Linter',
  tagline: 'Dart Code Linter is a software analytics tool that helps developers analyse and improve software quality. Dart Code Linter is based on a fork of Dart Code Metrics. We welcome contributions from other developers. Please feel free to submit pull-requests and bugreports to this GitHub repository. ',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://dcl.apps.bancolombia.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'Bancolombia', // Usually your GitHub org/user name.
  projectName: 'dart-code-linter', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en','es'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),

          editUrl:
            'https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source',
        },
        blog: {
          showReadingTime: true,
          editUrl:
            'https://github.com/bancolombia/dart-code-linter/tree/gh-pages-source',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/dcl.png',
      navbar: {
        title: 'Dart Code Linter',
        logo: {
          alt: 'Dart Code Linter Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://medium.com/bancolombia-tech',
            label: 'Blog',
            position: 'left',
          },
         { type: 'localeDropdown',
         position: 'right',
        },
          {
            href: 'https://github.com/bancolombia/dart-code-linter/',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Rules',
                to: '/docs/rules',
              },
              {
                label: 'Metrics',
                to: '/docs/metrics',
              },
              {
                label: 'Anti Patterns',
                to: '/docs/anti-patterns',
              },
              {
                label: 'Presets',
                to: '/docs/configuration/presets',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Changelog',
                href: 'https://github.com/bancolombia/dart-code-linter/blob/trunk/CHANGELOG.md',
              },
              {
                label: 'Contributing',
                href: 'https://github.com/bancolombia/dart-code-linter/blob/trunk/CONTRIBUTING.md',
              },
              {
                label: 'Troubleshooting',
                href: 'https://github.com/bancolombia/dart-code-linter/blob/trunk/TROUBLESHOOTING.md',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Bancolombia Tech',
                href: 'https://medium.com/bancolombia-tech',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/bancolombia/dart-code-linter',
              },
              {
                label: 'Pub.dev',
                href: 'https://pub.dev/packages/dart_code_linter',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Grupo Bancolombia.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
      algolia: {
        appId: 'QWTQS8Z7VD',
        apiKey: '550f018cc6605cd38b22775e427da2e5',
        indexName: 'dcls-bancolombia-co',
        contextualSearch: true,
        searchParameters: {},
        searchPagePath: 'search',
  
      },
    }),
};

module.exports = config;
