const { sayHello } = require('../src/index');

describe('sayHello()', () => {
  test('devuelve "Hello, World!" si no se pasa ningún nombre', () => {
    expect(sayHello()).toBe('Hello, World!');
  });

  test('devuelve saludo personalizado si se pasa un nombre', () => {
    expect(sayHello('Enver')).toBe('Hello, Enver!');
  });
});
