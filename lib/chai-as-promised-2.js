(function (chaiAsPromised) {
    "use strict";

    // Module systems magic dance.

    if (typeof require === "function" && typeof exports === "object" && typeof module === "object") {
        // NodeJS
        module.exports = chaiAsPromised;
    } else if (typeof define === "function" && define.amd) {
        // AMD
        define(function () {
            return chaiAsPromised;
        });
    } else {
        // Other environment (usually <script> tag): plug in to global chai instance directly.
        chai.use(chaiAsPromised);
    }
}(function chaiAsPromised(chai, utils) {
    "use strict";

    var Assertion = chai.Assertion;

    function assertIsAboutPromise(assertion) {
        if (typeof assertion._obj.then !== "function") {
            throw new TypeError(utils.inspect(assertion._obj) + " is not a thenable.");
        }
        if (typeof assertion._obj.pipe === "function") {
            throw new TypeError("Chai as Promised is incompatible with jQuery's thenables, sorry! Please use a " +
                                "Promises/A+ compatible library (see http://promisesaplus.com/).");
        }
    }

    function method(name, asserter) {
        utils.addMethod(Assertion.prototype, name, function () {
            assertIsAboutPromise(this);
            return asserter.apply(this, arguments);
        });
    }

    function property(name, asserter) {
        utils.addProperty(Assertion.prototype, name, function () {
            assertIsAboutPromise(this);
            return asserter.apply(this, arguments);
        });
    }

    // These are for clarity and to bypass Chai refusing to allow `undefined` as actual when used with `assert`.
    function assertIfNegated(assertion, message, extra) {
        assertion.assert(true, null, message, extra.expected, extra.actual);
    }

    function assertIfNotNegated(assertion, message, extra) {
        assertion.assert(false, message, null, extra.expected, extra.actual);
    }

    // Grab the list of methods that need overwriting to respect `eventually`, before we add our own promise-specific
    // ones. We need to be careful not to trigger any getters, thus `Object.getOwnPropertyDescriptor` usage.
    var methodNames = Object.getOwnPropertyNames(Assertion.prototype).filter(function (name) {
        return name !== "assert" &&
               typeof Object.getOwnPropertyDescriptor(Assertion.prototype, name).value === "function";
    });

    property("fulfilled", function () {
        var that = this;
        var derivedPromise = that._obj.then(
            function (value) {
                assertIfNegated(that,
                                "expected promise not to be fulfilled but it was fulfilled with #{act}",
                                { actual: value });
            },
            function (reason) {
                assertIfNotNegated(that,
                                   "expected promise to be fulfilled but it was rejected with #{act}",
                                   { actual: reason });
            });

        that.then = derivedPromise.then.bind(derivedPromise);
    });

    property("rejected", function () {
        var that = this;
        var derivedPromise = that._obj.then(
            function (value) {
                assertIfNotNegated(that,
                                   "expected promise to be rejected but it was fulfilled with #{act}",
                                   { actual: value });
            },
            function (reason) {
                assertIfNegated(that,
                                "expected promise not to be rejected but it was rejected with #{act}",
                                { actual: reason });
            }
        );

        that.then = derivedPromise.then.bind(derivedPromise);
    });

    method("rejectedWith", function (Constructor, message) {
        var desiredReason = null;
        var constructorName = null;

        if (Constructor instanceof RegExp || typeof Constructor === "string") {
            message = Constructor;
            Constructor = null;
        } else if (Constructor && Constructor instanceof Error) {
            desiredReason = Constructor;
            Constructor = null;
            message = null;
        } else if (typeof Constructor === "function") {
            constructorName = (new Constructor()).name;
        } else {
            Constructor = null;
        }

        var that = this;
        var derivedPromise = that._obj.then(
            function (value) {
                var assertionMessage = null;
                var expected = null;

                if (Constructor) {
                    assertionMessage = "expected promise to be rejected with #{exp} but it was fulfilled with #{act}";
                    expected = constructorName;
                } else if (message) {
                    var verb = message instanceof RegExp ? "matching" : "including";
                    assertionMessage = "expected promise to be rejected with an error " + verb + " #{exp} but it was " +
                                       "fulfilled with #{act}";
                    expected = message;
                } else if (desiredReason) {
                    assertionMessage = "expected promise to be rejected with #{exp} but it was fulfilled with #{act}";
                    expected = desiredReason;
                }

                assertIfNotNegated(that, assertionMessage, { expected: expected, actual: value });
            },
            function (reason) {
                if (Constructor) {
                    that.assert(reason instanceof Constructor,
                                "expected promise to be rejected with #{exp} but it was rejected with #{act}",
                                "expected promise not to be rejected with #{exp} but it was rejected with #{act}",
                                constructorName,
                                reason);
                }

                var reasonMessage = utils.type(reason) === "object" && "message" in reason ?
                                        reason.message :
                                        "" + reason;
                if (message && reasonMessage !== null && reasonMessage !== undefined) {
                    if (message instanceof RegExp) {
                        that.assert(message.test(reasonMessage),
                                    "expected promise to be rejected with an error matching #{exp} but got #{act}",
                                    "expected promise not to be rejected with an error matching #{exp}",
                                    message,
                                    reasonMessage);
                    }
                    if (typeof message === "string") {
                        that.assert(reasonMessage.indexOf(message) !== -1,
                                    "expected promise to be rejected with an error including #{exp} but got #{act}",
                                    "expected promise not to be rejected with an error including #{exp}",
                                    message,
                                    reasonMessage);
                    }
                }

                if (desiredReason) {
                    that.assert(reason === desiredReason,
                                "expected promise to be rejected with #{exp} but it was rejected with #{act}",
                                "expected promise not to be rejected with #{exp}",
                                desiredReason,
                                reason);
                }
            }
        );

        that.then = derivedPromise.then.bind(derivedPromise);
    });

    property("eventually", function () {
        utils.flag(this, "eventually", true);
    });

    method("notify", function (done) {
        this._obj.then(function () { done(); }, done);
    });

    method("become", function (value) {
        return this.eventually.deep.equal(value);
    });

    methodNames.forEach(function (methodName) {
        Assertion.overwriteMethod(methodName, function (originalMethod) {
            return function () {
                var that = this;
                var args = arguments;

                if (!utils.flag(that, "eventually")) {
                    return originalMethod.apply(that, args);
                }

                console.log("eventually! but ...", methodName, that._obj);

                var derivedPromise = that._obj.then(function (value) {
                    that._obj = value;
                    originalMethod.apply(that, args);
                });

                that.then = derivedPromise.then.bind(derivedPromise);
            };
        });
    })
}));
