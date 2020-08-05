#!/usr/bin/env node

const fs = require('fs');
const inquirer = require('inquirer');
const template = require('lodash/template');
const cloneDeep = require('lodash/cloneDeep');

const required = (value) => {
  if (value.length > 3) {
    return true;
  }

  return 'Must be entered.';
};

const writeConfiguration = (answers) => {
  const wpaSupplicantTemplate = fs.readFileSync('./lib/boot/wpa_supplicant.conf.template', 'utf-8');
  const wpaSupplicant = template(wpaSupplicantTemplate);
  fs.writeFileSync('./lib/boot/wpa_supplicant.conf', wpaSupplicant(answers));
  fs.writeFileSync('./lib/root/hostname', `${answers.RPI_HOSTNAME}`);
  fs.writeFileSync('./lib/root/timezone', `${answers.RPI_TIMEZONE}`);
}

const preAnswers = cloneDeep(process.env);
const questions = [
  {
    type: 'input',
    name: 'WPA_SSID',
    message: 'Wifi SSID',
    validate: required,
    when: !preAnswers.WPA_SSID
  },
  {
    type: 'input',
    name: 'WPA_PASSPHRASE',
    message: 'Wifi Passphrase',
    validate: required,
    when: !preAnswers.WPA_SSID
  },
  {
    type: 'input',
    name: 'RPI_HOSTNAME',
    message: 'Hostname',
    default: 'beholder-01.local',
    validate: required,
    when: !preAnswers.WPA_SSID
  },
  {
    type: 'input',
    name: 'RPI_TIMEZONE',
    message: 'Time Zone',
    default: 'America/New_York',
    validate: required,
    when: !preAnswers.WPA_SSID
  },
];

inquirer
  .prompt(questions)
  .then(answers => {
    writeConfiguration({
      ...preAnswers,
      answers
    })
  })
  .catch(error => {
    if (error.isTtyError) {
      // Fall back to using env variables to determine configuration.
      writeConfiguration(preAnswers)
    } else {
      throw error
    }
  });
