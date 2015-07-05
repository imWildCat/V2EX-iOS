class StringExtension {

}

if(!String.prototype.startsWith){
    String.prototype.startsWith = function (str) {
        return !this.indexOf(str);
    }
}

export default StringExtension;