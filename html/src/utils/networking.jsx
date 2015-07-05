class Networking {
    static loadURL(url) {
        var iFrame;
        iFrame = document.createElement('iFrame');
        iFrame.setAttribute('src', url);
        iFrame.setAttribute('style', 'display: none;');
        iFrame.setAttribute('height', '0px');
        iFrame.setAttribute('width', '0px');
        iFrame.setAttribute('frameborder', '0');
        document.body.appendChild(iFrame);
        iFrame.parentNode.removeChild(iFrame);
        iFrame = null;
        console.log("Networking.loadURL(\"" + url + "\")");
    }
}

export default Networking;