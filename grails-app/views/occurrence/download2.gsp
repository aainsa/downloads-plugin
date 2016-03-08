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
    <title>ALA Data Download</title>
    <r:require module="download"/>
    <style type="text/css">
        a .fa {
            width: 18px;
            margin-right: 5px;
        }
        .list-group-item {
            padding:8px 12px;
        }

</style>
</head>
<body>
<div class="row">
    <div class="span10">
        <h1 class="hidden">Welcome to the Atlas of Living Australia website</h1><!-- Show the H1 on each page -->

        <!-- Breadcrumb -->
        <ol class="breadcrumb hidden-print">
            <li><a class="font-xxsmall" href="${grailsApplication.config.organisation.baseUrl}">Home</a><span class="divider">/</span></li>
            <li><a class="font-xxsmall" href="${g.createLink(uri:'/')}">Occurrence Records</a><span class="divider">/</span></li>
            <li class="font-xxsmall active">Download</li>
        </ol>
        <!-- End Breadcrumb -->
        <h2 class="heading-medium">Customise Your Download</h2>
        <g:set var="toolbar">
            <div class="button-toolbar row-fluid">
                <div class="btn-group">
                    <!-- <a class="btn btn-default" disabled="disabled" href="#"><span class="glyphicon glyphicon-th" aria-hidden="true"></span> <span class="hidden-xs hidden-sm">Toggle grid view</span></a> -->
                    <a class="btn btn-default select-all-btn" href="#"><i class="fa fa-check"></i> <span class="hidden-xs hidden-sm">Select all</span></a>
                    <a class="btn btn-default select-none-btn" href="#"><i class="fa fa-times"></i> <span class="hidden-xs hidden-sm">Unselect all</span></a>
                </div>
                <div class="btn-group pull-right">
                    <a class="btn btn-default save-btn"><i class="fa fa-cog"></i> <span class="hidden-xs">Save preferences</span></a>
                    <a class="btn btn-primary next-btn" href="#"><span class="hidden-xs">Next <i class="fa fa-chevron-right"></i></span></a>
                </div>
            </div>
        </g:set>
        <g:set var="selectedItem" value="fa-toggle-on"/>
        <g:set var="unselectedItem" value="fa-toggle-off"/>

        ${raw(toolbar)}

        <g:each in="${customSections}" var="section">
            <div class="well">
                <div class="row-fluid">
                    <div class="span12">
                        <div class="panel panel-default">
                            <div class="comment-wrapper push">
                                <div class="row-fluid">
                                    <div class="span2  hidden-phone">
                                        <div class="contrib-stats">
                                            <div class="no-of-questions">
                                                <div class="survey-details">
                                                    <div class="survey-counter"><strong><i class="fa fa-cog color--yellow"></i></strong></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="span8">
                                        <h4 class="text-uppercase heading-underlined"><g:message code="section.${section.key}" default="${section.key}"/></h4>
                                        <p class="margin-bottom-2">
                                            <g:message code="section.description.${group}" default="A description of the field groupings below"/>.
                                        </p>

                                        <div class="list-group">
                                            <g:each in="${section.value}" var="group" status="i">
                                                <g:set var="disabled" value="${(mandatoryFields.contains(group)) ? true : false }"/>
                                                <g:set var="active" value="${(mandatoryFields.contains(group) || userSavedFields.contains(group)) ? true : false }"/>
                                                <a href="#" class="list-group-item ${(disabled)?"disabled":""} ${(active)?"list-group-item-success":""}">
                                                    <div class="checkbox pull-left">
                                                        <label><input type="checkbox" value="${group}" ${(disabled || active)?"checked='checked'":""}></label>
                                                    </div>
                                                    <div class="pull-left form-control-inline">
                                                        <h4 class="padding-left-1">
                                                            <i class="fa  ${(disabled || active)? selectedItem : unselectedItem}"></i>
                                                            <g:message code="customGroup.${group}" default="${group}"/>
                                                        </h4>
                                                    </div>
                                                    <div class="clearfix"></div>
                                                </a>
                                            </g:each>
                                        </div>

                                    </div>
                                </div>
                            </div><!-- End comment-wrapper push -->
                        </div>
                    </div>
                </div>
            </div>
        </g:each>

        ${raw(toolbar)}

    </div>
</div>
<g:javascript>
    $( document ).ready(function() {
        // catch clicks on list group items
        $('a.list-group-item').not('.disabled').click(function(e) {
            e.preventDefault(); // its link so stop any regular link stuff hapenning
            var link = this;
            if ($(link).hasClass('list-group-item-success')) {
                // already selected
                deselectItem(link);
            } else {
                // not selected
                selectItem(link);
            }
        });

        $('.select-all-btn').click(function(e) {
            e.preventDefault();
            $('a.list-group-item').not('.disabled').each(function(i) {
                selectItem(this);
            });
        });

        $('.select-none-btn').click(function(e) {
            e.preventDefault();
            $('a.list-group-item').not('.disabled').each(function(i) {
                deselectItem(this);
            });
        });

    });

    function selectItem(item) {
        $(item).find('i.fa').removeClass('${unselectedItem}');
        $(item).find('i.fa').addClass('${selectedItem}');
        $(item).addClass('list-group-item-success');
        $(item).find('input').attr('checked','checked');
        $(item).blur(); // prevent BS focus
    }

    function deselectItem(item) {
        $(item).removeClass('disabled').removeClass('list-group-item-success');
        $(item).find('.fa').addClass('${unselectedItem}');
        $(item).find('.fa').removeClass('${selectedItem}');
        $(item).find('input').removeAttr('checked');
        $(item).blur(); // prevent BS focus
    }

</g:javascript>
</body>
</html>