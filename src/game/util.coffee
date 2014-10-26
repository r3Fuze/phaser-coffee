module.exports.randomHex = (prefix = "0x") ->
    return prefix + Math.floor(Math.random() * 16777215).toString 16
