module.exports = {
  root: true,
  env: {
    node: true
  },
  extends: [
    'plugin:vue/essential',
    '@vue/standard',
    '@vue/typescript/recommended'
  ],
  parserOptions: {
    ecmaVersion: 2020
  },
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    // modified rules to align with code formatter and personal preference
    'quotes': ['error', 'double'],
    'semi': ['error', 'always'],
    'comma-dangle': 'off',
    'space-before-function-paren': 'off'
  }
}
