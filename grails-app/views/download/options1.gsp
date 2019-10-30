%{--
  - Copyright (C) 2016 Atlas of Living Australia
  - All Rights Reserved.
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 22/02/2016
  Time: 1:53 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <meta name="fluidLayout" content="false"/>
    <meta name="breadcrumbParent" content="${request.contextPath ?: '/'},${message(code: "download.occurrence.records")}"/>
    <meta name="breadcrumb" content="${message(code: "download.breadcumb.title")}"/>
    <title><g:message code="download.page.title"/></title>
    <asset:javascript src="downloads.js" />
    <asset:stylesheet src="downloads.css" />
</head>

<body>
<div class="row">
    <div class="col-md-10 col-md-offset-1">

        <h2 class="heading-medium"><g:message code="download.download.title"/></h2>
        <g:set var="showLongTimeWarning" value="${totalRecords && (totalRecords > grailsApplication.config.downloads.maxRecords)}"/>

        <!-- Long download warning -->
        <g:if test="${showLongTimeWarning || grailsApplication.config.downloads.staticDownloadsUrl}">
        <div class="alert alert-info" role="alert">
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <strong>
                <g:if test="${showLongTimeWarning}">
                    Your search returned ${g.formatNumber(number: totalRecords, format: "#,###,###")} results and may take more than 24 hours to run.
                </g:if>
                <g:if test="${showLongTimeWarning && grailsApplication.config.downloads.staticDownloadsUrl}">
                    <br/>
                </g:if>
                <g:if test="${grailsApplication.config.downloads.staticDownloadsUrl}">
                    Did you know the ${grailsApplication.config.skin.orgNameLong} provides a number of pre-generated downloads for common search queries
                    (e.g. all plants, mammals, birds, insects, etc.)?
                    <a href="${grailsApplication.config.downloads.staticDownloadsUrl?:'http://downloads.ala.org.au'}" target="_blank">
                        View all pre-generated downloads.
                    </a>
                </g:if>
            </strong>
        </div>
        </g:if>

        <div class="well">
            <div id="grid-view" class="row">
                <div class="col-md-12">
                    %{--<div class="panel panel-default">--}%
                        <div class="comment-wrapper push">

                            <div class="row ">
                                <div class="col-md-2">
                                    <h4 class="heading-medium-alt"><g:message code="download.step1" /></h4>
                                </div>

                                <div class="col-md-10">
                                    <p><g:message code="download.select.download.type" /></p>
                                </div>
                            </div>
                        <div class="row margin-top-1">
                            <div class="col-md-2">
                                <div class="contrib-stats">
                                    <div class="no-of-questions">
                                        <div class="survey-details">
                                            <div class="survey-counter"><strong><i
                                                    class="fa fa-table color--yellow"></i></strong></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <g:if test="${!defaults?.downloadType || defaults?.downloadType == 'records'}">
                                <div class="col-md-7">
                                    <h4 class="text-uppercase=heading-underlined"><g:message code="download.occurrence.records" /></h4>
                                    <p>
                                        <g:message code="download.occurrence.records.zip" />
                                    </p>
                                    <form id="downloadFormatForm" class="form-horizontal collapse">
                                        <div class="form-group">
                                            <label for="file" class="control-label col-sm-4"><g:message code="download.occurrence.records.filename" /></label>
                                            <div class="col-sm-8">
                                                <input type="text" id="file" name="file" value="${filename}"
                                                       class="input form-control"/>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label for="downloadFormat" class="control-label col-sm-4">
                                                <span class="color--mellow-red" style="font-size:18px">*</span>
                                                Download format
                                            </label>
                                            <div class="col-sm-8 radio">
                                                <g:each in="${au.org.ala.downloads.DownloadFormat.values()}" var="df">
                                                    <div class="">
                                                        <label>
                                                            <input type="radio" name="downloadFormat" id="downloadFormat" class=""
                                                                   value="${df.format}" ${downloads.isDefaultDownloadFormat(df: df)} />
                                                            <g:message code="format.${df.format}"/> <g:message code="helpicon.${df.format}" args="[ g.createLink(action:'fields') ]" default=""/>
                                                        </label>
                                                    </div>
                                                </g:each>
                                                <p class="help-block collapse"><strong>This field is mandatory.</strong></p>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-sm-4">
                                                <span class="color--mellow-red" style="font-size:18px">*</span>
                                                Output file format
                                            </label>
                                            <div class="col-sm-8 radio">
                                                <g:each in="${au.org.ala.downloads.FileType.values()}" var="ft">
%{--                                                %{-- Skip Shapefile type --}%
                                                    <g:if test="${!(grailsApplication.config.getProperty("filetype.shapefile.disable", boolean) && ft.type == au.org.ala.downloads.FileType.SHAPE.type )}">
                                                        <div class="">
                                                            <label>
                                                                <input id="fileType_${ft.type}" type="radio" name="fileType" class=""
                                                                       value="${ft.type}" ${(ft.ordinal() == 0) ? 'checked' : ''}/>
                                                                <g:message code="type.${ft.type}"/> <g:message
                                                                        code="helpicon.${ft.type}" default=""/>
                                                            </label>
                                                        </div>
                                                    </g:if>
                                                </g:each>
                                                <g:if test="${grailsApplication.config.getProperty("filetype.shapefile.disable", boolean)}">
                                                    %{-- Indicate shapefile is deprecated and will be removed --}%
                                                    <div class="">
                                                        <label>
                                                            <input type="radio" name="fileType" value="shapefile" disabled="disabled" />
                                                            <span style="opacity: 0.8;"><g:message code="type.shapefile.disabled" args="[ grailsApplication.config.getProperty('shapefile.kb.url') ]" /></span>
                                                        </label>
                                                    </div>
                                                </g:if>
                                            </div>
                                        </div>
                                    </form>
                                </div>

                                <div class="col-md-3">
                                    <a href="#" id="select-${au.org.ala.downloads.DownloadType.RECORDS.type}"
                                       class="select-download-type btn btn-white btn-lg btn-block margin-top-1 margin-bottom-1 font-xxsmall"
                                       type="button">
                                        <i class="glyphicon glyphicon-ok" style="display: none;"></i><span>Select</span>
                                    </a>
                                </div><!-- End col-md-3 -->
                                <hr class="visible-xs"/>
                                </div><!-- End row -->
                            </g:if>
                            <g:if test="${!defaults?.downloadType || defaults?.downloadType == 'checklist'}">
                                <div class="row margin-top-1">
                                    <div class="col-md-2">
                                        <div class="contrib-stats">
                                            <div class="no-of-questions">
                                                <div class="survey-details">
                                                    <div class="survey-counter"><strong><i
                                                            class="fa fa-list-alt color--apple"></i></strong></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-7">
                                        <h4 class="text-uppercase=heading-underlined">Species checklist</h4>

                                        <p class="font-xsmall">
                                            A comma separated values (CSV) file, listing the distinct species in the occurrence records
                                            result set.
                                        </p>
                                    </div>

                                    <div class="col-md-3">

                                        <a href="#" id="select-${au.org.ala.downloads.DownloadType.CHECKLIST.type}"
                                           class="select-download-type btn btn-white btn-lg btn-block margin-top-1 margin-bottom-1 font-xxsmall"
                                           type="button">
                                            <i class="glyphicon glyphicon-ok collapse"></i><span>Select</span>
                                        </a>
                                    </div><!-- End col-md-3 -->
                                    <hr class="visible-xs"/>
                                </div><!-- End row -->
                            </g:if>

                            <g:if test="${ grailsApplication.config.downloads.fieldguideDownloadUrl && (!defaults?.downloadType || defaults?.downloadType == 'fieldguide')}">
                                <div class="row margin-top-1">
                                    <div class="col-md-2">
                                        <div class="contrib-stats">
                                            <div class="no-of-questions">
                                                <div class="survey-details">
                                                    <div class="survey-counter"><strong><i
                                                            class="fa fa-file-pdf-o color--mellow-red"></i></strong>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-7">
                                        <h4 class="text-uppercase=heading-underlined">Species field-guide</h4>

                                        <p>
                                            A PDF document containing species profile information (including photos and maps) for the
                                            list of distinct species in the occurrence record set.
                                        </p>
                                    </div>

                                    <div class="col-md-3">
                                        <a href="#" id="select-${au.org.ala.downloads.DownloadType.FIELDGUIDE.type}"
                                           class="select-download-type btn btn-white btn-lg btn-block margin-top-1 margin-bottom-1 font-xxsmall"
                                           type="button">
                                            <i class="glyphicon glyphicon-ok" style="display: none;"></i><span>Select</span>
                                        </a>
                                    </div><!-- End col-md-3 -->
                                </div><!-- End row -->
                            </g:if>
                        </div><!-- End comment-wrapper push -->
                    %{--</div><!-- End panel -->--}%
                </div>
            </div>
        </div>

        <div class="well">
            <div class="row">
                <div class="col-md-12">
                    <!-- <h4>Species Download</h4> -->
                    %{--<div class="panel panel-default">--}%
                        <div class="comment-wrapper push">
                            <div class="row">
                                <div class="col-md-2">
                                    <h4 class="heading-medium-alt">Step 2</h4>
                                </div>

                                <div class="col-md-10">
                                    <p>Select your download reason and then click the "Next" button.</p>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-2">
                                    <div class="contrib-stats">
                                        <div class="no-of-questions">
                                            <div class="survey-details">
                                                <div class="survey-counter"><strong><i
                                                        class="fa fa-tags color--apple"></i></strong></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-7">
                                    <form class="form-inline margin-top-1">
                                        <div class="form-group">
                                            <label for="downloadReason" class="control-label heading-xsmall"><span
                                                    class="color--mellow-red">*</span>Industry/application</label>&nbsp;&nbsp;
                                            <select class="form-control" id="downloadReason">
                                                <option value="" disabled selected>Select a reason ...</option>
                                                <g:each var="it" in="${downloads.getLoggerReasons()}">
                                                    <option value="${it.id}">${it.name}</option>
                                                </g:each>
                                            </select>
                                            <p class="help-block"><strong>This field is mandatory.</strong> Choose the best "use type" from the drop-down menu above.
                                            </p>
                                        </div>
                                    </form>
                                </div>

                                <div class="col-md-3">
                                    <a href="#" id="nextBtn"
                                       class="btn btn-lg btn-primary btn-bs3 btn-block margin-top-1 margin-bottom-1 font-xxsmall"
                                       type="button">Next <i class="fa fa-chevron-right color--white"></i></a>
                                </div><!-- End col-md-3 -->
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <!-- Alert Information -->
                                    <div id="errorAlert" class="alert alert-danger alert-dismissible collapse" role="alert">
                                        <button type="button" class="close" onclick="$(this).parent().hide()"
                                                aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                        <strong>Error:</strong> Ensure that you 1) select your download <b>type</b><span
                                            id="errorFormat" class="collapse">and select a download <b>format</b>
                                    </span>, 2) select a download <b>reason</b>

                                    </div>
                                    <!-- End Alert Information -->
                                </div>
                            </div><!-- End body -->
                        </div><!-- End comment-wrapper push -->
                    %{--</div>--}%
                </div>
            </div>
        </div><!-- End .well -->
        <div class="alert alert-info alert-dismissible" role="alert">
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span
                    aria-hidden="true">×</span></button>
            <g:message code="download.termsofusedownload.01" />
            <a href="${grailsApplication.config.downloads.termsOfUseUrl}"><g:message code="download.termsofusedownload.02" /></a>
            <g:message code="download.termsofusedownload.03" />
        </div>
    </div><!-- /.col-md-10  -->
</div><!-- /.row-fuid  -->
<div class="hidden">
    <g:form id="hiddenForm" url="[action:'confirm']" method="${requestMethod}" useToken="true">
        <g:set var="properties" value="${["searchParams","targetUri","downloadType","reasonTypeId","sourceTypeId","downloadFormat","file","layers","customHeader","fileType","layersServiceUrl"]}"/>
        <g:each in="${properties}" var="prop">
            <input type="hidden" name="${prop}" id="${prop}" value="${downloadParams[prop]}"/>
        </g:each>
    </g:form>
</div>
<g:javascript>
    $( document ).ready(function() {
        // click event on download type select buttons
        $('a.select-download-type').click(function(e) {
            e.preventDefault(); // its a link so stop any regular link stuff happening
            var link = this;
            if ($(link).hasClass('btn-success')) {
                // already selected so de-select it
                $(link).find('span').text('Select');
                $(link).removeClass('btn-success');
                $(link).addClass('btn-white');
                $(link).find('.glyphicon').hide();
                $(link).blur(); // prevent BS focus

                if ($(link).attr('id') == "select-${au.org.ala.downloads.DownloadType.RECORDS.type}") {
                    // show type options
                    $('#downloadFormatForm').slideUp();
                }
            } else {
                // not selected
                $('a.select-download-type').find('span').text('Select'); // reset any other selected buttons
                $('a.select-download-type').removeClass('btn-success'); // reset any other selected buttons
                $('a.select-download-type').addClass('btn-white'); // reset any other selected buttons
                $('a.select-download-type').find('.glyphicon').hide(); // reset any other selected buttons
                $(link).find('span').text('Selected');
                $(link).removeClass('btn-white');
                $(link).addClass('btn-success');
                $(link).find('.glyphicon').show();
                $(link).blur(); // prevent BS focus
                //console.log('link id', $(link).attr('id'), "select-${au.org.ala.downloads.DownloadType.RECORDS.type}");

                if ($(link).attr('id') == "select-${au.org.ala.downloads.DownloadType.RECORDS.type}") {
                    // show type options
                    $('#downloadFormatForm').slideDown();
                } else {
                    $('#downloadFormatForm').slideUp();
                    $('#downloadReason').focus();
                }
            }
        });

        if (${defaults?.downloadType != null}) {
            $('#select-${defaults?.downloadType}').click();
        }

        // download format change event
        $('#downloadFormat').on('change', function(e) {
            //console.log('this selected val', $(this).find(":selected").val());
            if ($(this).find(":selected").val()) {
                // set focus on reason code
                $('#downloadReason').focus();
            }
        });

        if (${defaults?.downloadFormat != null}) {
            //$('#downloadFormat')[0].value = '${defaults?.downloadFormat}';
            $('input[name=downloadFormat]:checked').val(${defaults?.downloadFormat});
        }

        if (${defaults?.fileType != null}) {
            //$('#fileType')[0].value = '${defaults?.fileType}';
            //$('input[name=fileType]:checked').val(${defaults?.downloadFormat});
        }

        // file type change event
        $('#fileType').on('change', function(e) {
            //console.log('this selected val', $(this).find(":selected").val());
            if ($(this).find(":selected").val()) {
                // set focus on reason code
                $('#downloadReason').focus();
            }
        });

        // click event on next button
        $('#nextBtn').click(function(e) {
            e.preventDefault();
            // do form validation
            var type = $('.select-download-type.btn-success').attr('id');
            //var format = $('#downloadFormat').find(":selected").val();
            var format = $('input[name=downloadFormat]:checked').val();
            var reason = $('#downloadReason').find(":selected").val();
            var file = $('#file').val();
            var requestMethod = "${requestMethod?:"GET"}";
            //alert("format = " + format);
            if (type) {
                type = type.replace(/^select-/,''); // remove prefix
                $('#errorAlert').hide();

                if (type == "${au.org.ala.downloads.DownloadType.RECORDS.type}") {
                    // check for format
                    if (!format) {
                        $('#downloadFormat').focus();
                        $('#errorAlert').show();
                        $('#errorFormat').show();
                        return false;
                    } else {
                        $('#errorFormat').hide();
                        $('#errorAlert').hide();
                    }
                }

                if (!reason) {
                    $('#errorAlert').show();
                    $('#downloadReason').focus();
                } else if (requestMethod == "POST") {
                    // go to next screen via POST
                    $('#errorAlert').hide();
                    // update hidden fields
                    $('#hiddenForm input#sourceTypeId').val("${downloads.getSourceId()}");
                    $('#hiddenForm input#layers').val("${defaults.layers}");
                    $('#hiddenForm input#layersServiceUrl').val("${defaults.layersServiceUrl}");
                    $('#hiddenForm input#customHeader').val("${defaults.customHeader}");
                    $('#hiddenForm input#fileType').val($('input[name=fileType]:checked').val());
                    $('#hiddenForm input#downloadType').val(type);
                    $('#hiddenForm input#reasonTypeId').val(reason);
                    $('#hiddenForm input#downloadFormat').val(format);
                    $('#hiddenForm input#file').val(file);
                    // submit form
                    $('#hiddenForm').submit();
                } else {
                    // go to next screen via GET (legacy)
                    $('#errorAlert').hide();
                    var sourceTypeId = "${downloads.getSourceId()}";
                    var layers = "${defaults.layers}";
                    var layersServiceUrl = "${defaults.layersServiceUrl}";
                    var customHeader = "${defaults.customHeader}";
                    var fileType = $('input[name=fileType]:checked').val();
                    window.location = "${g.createLink(action: 'confirm')}?searchParams=${searchParams.encodeAsURL()}&targetUri=${targetUri.encodeAsURL()}&downloadType="
                            + type + "&reasonTypeId=" + reason + "&sourceTypeId=" + sourceTypeId + "&downloadFormat=" + format + "&file=" + file + "&layers="
                            + layers + "&customHeader=" + customHeader + "&fileType=" + fileType + "&layersServiceUrl=" + layersServiceUrl;
                }
            } else {
                $('#errorAlert').show();
            }
        });

        var flashMessage = "${flash.message}";
        if (flashMessage) {
            $('#errorAlert').show();
        }

        // add BS tooltips trigger
        $(".tooltips").popover({
            trigger: 'hover',
            placement: 'top',
            delay: { show: 100, hide: 2500 },
            html: true
        });

        $(document).on('show.bs.popover', function (e) {
            // hide any lingering tooltips
            $(".popover.in").removeClass('in');
        });
    });
</g:javascript>
</body>
</html>