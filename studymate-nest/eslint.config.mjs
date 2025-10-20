// @ts-check
import eslint from '@eslint/js'
import globals from 'globals'
import tseslint from 'typescript-eslint'
import prettierRecommended from 'eslint-plugin-prettier/recommended'

export default tseslint.config(
  // Ignora tu propio config para que no se analice
  { ignores: ['eslint.config.mjs', 'dist', 'node_modules'] },

  // Reglas base de ESLint
  eslint.configs.recommended,

  // ⚠️ Sin type-checking: usar "recommended" (NO recommendedTypeChecked)
  ...tseslint.configs.recommended,

  // Prettier integradito
  prettierRecommended,

  // Setup general
  {
    languageOptions: {
      globals: { ...globals.node },
      // Si tu proyecto es CommonJS, usa 'commonjs'; si ESM, 'module'
      sourceType: 'commonjs',
      parserOptions: {
        // SIN "projectService"/"project": desactiva el modo type-checked
        ecmaVersion: 2021,
      },
    },
  },

  // Reglas locales
  {
    rules: {
      // Mantén el repo prolijo
      'prettier/prettier': ['error', { endOfLine: 'auto' }],
      // Buenas prácticas sin ponerse tóxico
      '@typescript-eslint/no-floating-promises': 'warn',
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-unsafe-argument': 'off',
      // Estas 4 son las que te rompen la vida; al no usar type-checking, ya no se activan
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/no-unsafe-call': 'off',
      '@typescript-eslint/no-unsafe-return': 'off',
      '@typescript-eslint/require-await': 'off',
    },
  },
)
