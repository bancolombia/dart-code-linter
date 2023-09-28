import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Detect problems',
    subtitle: '1.',
    description: (
      <>
        Quickly find and fix problems in your code.
      </>
    ),
  },
  {
    title: 'Calculate metrics',
    subtitle: '2.',
    description: (
      <>
        Detect places that need attention.
      </>
    ),
  },
  {
    title: 'Find unused code',
    subtitle: '3.',
    description: (
      <>
        Check if any code is unused.
      </>
    ),
  },
  {
    title: 'Use with your favorite IDE',
    subtitle: '4.',
    description: (
      <>
        View problems with your favorite editor.
      </>
    ),
  }
];

function Feature({subtitle, title, description}) {
  return (
    <div className={clsx('col col--3')}>
      <div className="text--center">
      <h2>{subtitle}</h2>
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
