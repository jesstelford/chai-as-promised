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
        utils.addMethod(chai.Assertion.prototype, name, function () {
            assertIsAboutPromise(this);
            return asserter.apply(this, arguments);
        });
    }

    function property(name, asserter) {
        utils.addProperty(chai.Assertion.prototype, name, function () {
            assertIsAboutPromise(this);
            return asserter.apply(this, arguments);
        });
    }

    // These are for clarity
    function assertIsNotNegated(assertion, messageIfNegated) {
        assertion.assert(true, null, messageIfNegated);
    }

    function assertIsNegated(assertion, messageIfNotNegated) {
        assertion.assert(false, messageIfNotNegated);
    }

    property("fulfilled", function () {
        var that = this;
        var derivedPromise = that._obj.then(
            function (value) {
                assertIsNotNegated(that, "expected promise not to be fulfilled but it was fulfilled with " +
                                         utils.inspect(value));
            },
            function (reason) {
                assertIsNegated(that, "expected promise to be fulfilled but it was rejected with " +
                                      utils.inspect(reason));
            });

        that.then = derivedPromise.then.bind(derivedPromise);
    });

    method("notify", function (done) {
        this._obj.then(function () { done(); }, done);
    })
}));
