var output = '';

$('#Main > div:nth-child(4) > div.cell > table > tbody > tr').each(function() {
    var catName = $(this).find('td:nth-child(1) > span').text();
    output += '<!--  ' + catName + '  -->';
    output += '<dict><key>category</key><string>' + catName + '</string><key>children</key><array>';

    $(this).find('td:nth-child(2) > a').each(function() {
        var nodeName = $(this).text();
        var nodeSlug = $(this).attr('href').replace('/go/', '');
        output += '<dict><key>name</key><string>' + nodeName + '</string><key>slug</key><string>' + nodeSlug + '</string></dict>';
    });

    output += '</array></dict>';
    output += '<!--  ' + catName + ' end  -->';
});

console.log(output);