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
    var assert = chai.assert;

});
