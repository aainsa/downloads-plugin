/*
 * Copyright (C) 2016 Atlas of Living Australia
 * All Rights Reserved.
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

package au.org.ala.downloads

import grails.converters.JSON
import grails.core.GrailsApplication
import grails.web.mapping.LinkGenerator
import org.springframework.beans.factory.annotation.Autowired

/**
 * Download controller
 * TODO: use more meaningful method names in this controller!
 */
class DownloadController {
    def customiseService, authService, downloadService, biocacheService, utilityService, doiService

    GrailsApplication grailsApplication

    @Autowired
    LinkGenerator linkGenerator

    static defaultAction = "index"

    /**
     * Initial download screen with options.
     *
     * @param downloadParams
     * @return
     */
    def index(DownloadParams downloadParams) {
        log.debug "biocacheDownloadParamString = ${downloadParams.biocacheDownloadParamString()}"
        log.debug "request.getHeader('referer') = ${request.getHeader('referer')}"
        log.debug "downloadParams = ${downloadParams.toString()}"
        downloadParams.file = DownloadType.RECORDS.type + "-" + new Date().format("yyyy-MM-dd")

        if (downloadParams.searchParams) {
            render (view:'options1', model: [
                    requestMethod: request.method,
                    downloadParams: downloadParams, // added later - other model objects now redundant! TODO cleanup code
                    searchParams: downloadParams.searchParams,
                    targetUri: downloadParams.targetUri,
                    filename: downloadParams.file,
                    totalRecords: downloadParams.totalRecords,
                    defaults: [ sourceTypeId: downloadParams.sourceTypeId,
                                downloadType: downloadParams.downloadType,
                                downloadFormat: downloadParams.downloadFormat,
                                fileType: downloadParams.fileType,
                                layers: downloadParams.layers,
                                layersServiceUrl: downloadParams.layersServiceUrl,
                                customHeader: downloadParams.customHeader]
            ])
        } else {
            flash.message = "${g.message(code:'download.error.noQueryParams', default:'Download error - No search query parameters were provided.')} "
            def redirectUri = request.getHeader('referer') ?: "/"
            redirect(uri: redirectUri)
        }
    }

    /**
     * Action after initial download screen.
     * Either redirects user to customise screen or to confirmation page & triggers download
     *
     * @param downloadParams
     * @return
     */
    def confirm(DownloadParams downloadParams) {
        log.debug "options2 request method = ${request.method}"
        downloadParams.email = authService?.getEmail() ?: downloadParams.email // if AUTH is not present then email should be populated via input on page
        downloadParams.searchUrl = linkGenerator.link(uri: downloadParams.targetUri?.replace(linkGenerator.contextPath,""), absolute:true) + downloadParams.searchParams

        // withForm allows duplicate submit events to be detected and caught
        withForm {
            if (downloadParams.downloadCompleted) {
                // catch a reload of the confirm page and prevent generating another download
                render(view:'confirm', model: [
                        isQueuedDownload: false,
                        downloadParams: downloadParams])
            } else if (!downloadParams.downloadType || !downloadParams.reasonTypeId) {
                flash.message = message(code:"download.error.noTypeReasonCode")
                redirect(action: "options1", params: params)
            } else if (downloadParams.downloadType == DownloadType.RECORDS.type && downloadParams.downloadFormat == DownloadFormat.CUSTOM.format && !downloadParams.customClasses) {
                // Customise download screen
                Map sectionsMap = biocacheService.getFieldsMap()
                log.debug "sectionsMap = ${sectionsMap as JSON}"
                Map customSections = grailsApplication.config.getProperty('downloads.customSections', Map, false).clone()
                // add preselected layer selection to "SPATIAL INTERSECTIONS"
                List mandatory = grailsApplication.config.getProperty('downloads.mandatoryFields', List, false).clone()

                if (downloadParams.layers) {
                    def sections = customSections.get("spatialIntersections")
                    if (sections) {
                        sections = sections.clone()
                        sections.add("selectedLayers")
                    } else {
                        customSections.put("spatialIntersections", ["selectedLayers"])
                    }
                    mandatory.add("selectedLayers")
                }

                render (view: 'options2', model: [
                        customSections: customSections,
                        mandatoryFields: mandatory,
                        dwcClassesAndTerms: utilityService.getFieldGroupMap(),
                        groupingsFilterMap: grailsApplication.config.getProperty('downloads.groupingsFilterMap', Map, [:]),
                        userSavedFields: customiseService.getUserSavedFields(request?.cookies?.find { it.name == 'download_fields'}, authService?.getUserId()),
                        downloadParams: downloadParams
                ])
            } else if (downloadParams.downloadType == DownloadType.RECORDS.type) {
                // Records download -> confirm
                // targetUri already contains the context path but linkGenerator does not know about it
                // hence we have to manually trim it.
                downloadParams.mintDoi = grailsApplication.config.getProperty('doi.mintDoi', Boolean, false)
                downloadParams.doiDisplayUrl = linkGenerator.link(controller: 'download', action: 'doi', params:[doi:''], absolute:true)
                downloadParams.hubName = grailsApplication.config.getProperty('info.app.description', String, "")
                Map jsonMap
                // perform the download
                try {
                    jsonMap = downloadService.triggerDownload(downloadParams)
                    downloadParams.downloadCompleted = true // prevent re-submitting via refresh
                    //chain (action:'confirm',
                    render (view:'confirm', model: [
                            isQueuedDownload: true,
                            downloadParams: downloadParams,
                            json: jsonMap // Map
                    ])
                } catch (Exception ex) {
                    log.warn "Failed to trigger download: ${ex.message}", ex
                    flash.message = message(code:"download.error.biocacheError") + ex.message
                    def redirectUri = downloadParams.searchUrl ?: downloadParams.targetUri
                    redirect(uri: redirectUri)
                }
            } else if (downloadParams.downloadType == DownloadType.CHECKLIST.type) {
                // Checklist download
                def extraParamsString = "&facets=species_guid&lookup=true&counts=true&lists=true"
                downloadParams.downloadCompleted = true // prevent re-submitting via refresh
                render (view:'confirm', model: [
                        isQueuedDownload: false,
                        isChecklist: true,
                        downloadParams: downloadParams,
                        downloadUrl: grailsApplication.config.getProperty('downloads.checklistDownloadUrl') + downloadParams.biocacheDownloadParamString() + extraParamsString
                ])
            } else if (downloadParams.downloadType == DownloadType.FIELDGUIDE.type) {
                // Field guide download
                downloadParams.downloadCompleted = true // prevent re-submitting via refresh
                def extraParamsString = "&facets=species_guid"
                render (view:'confirm', model: [
                        isQueuedDownload: false,
                        isFieldGuide: true,
                        downloadParams: downloadParams,
                        json: downloadService.triggerFieldGuideDownload(downloadParams.biocacheDownloadParamString() + extraParamsString),
                        downloadUrl: grailsApplication.config.getProperty('downloads.fieldguideDownloadUrl') + downloadParams.biocacheDownloadParamString() + extraParamsString
                ])
            } else {
                log.warn "Fell through `downloadType` if-else -> downloadParams = ${downloadParams}"
                flash.message = message(code:"download.error.unknown")
                redirect(uri: "${downloadParams.searchUrl ?: downloadParams.targetUri}")
            }
        }.invalidToken {
            // bad request
            log.warn "Invalid token - form might've been submitted multiple times."
            flash.message = message(code:"download.error.multipleSubmit")
            redirect(uri: "${downloadParams.searchUrl ?: downloadParams.targetUri}")
        }
    }

    /**
     * Paginated list of downloads for logged-in user
     *
     * @return
     */
    def myDownloads() {
        redirect url: "${grailsApplication.config.getProperty('doiService.baseUrl')}/myDownloads"
    }

    /**
     * View a download via it's DOI identifier (lookup)
     *
     * @return
     */
    def doi() {
        redirect url: "${grailsApplication.config.getProperty('doiService.baseUrl')}/doi/${params?.doi}"
    }

    /**
     * Remember the user's options for customise download page
     *
     * @return
     */
    def saveUserPrefs() {
        List fields = params.list("fields")

        try {
            def res = customiseService.setUserSavedFields(authService?.getUserId(), fields)
            response.status = res?.statusCode?:200
            render res as JSON
        } catch (Exception ex) {
            log.error("Error saving user preferences: ${ex.message}", ex)
            render(status: "400", text: "Error saving user preferences: ${ex.message}")
        }

    }

    /**
     * Display the description attribute for a download field (via it's ID)
     *
     * @param id
     * @return
     */
    def getDescription(String id) {
        if (id) {
            String description = biocacheService.getDwCDescriptionForField(id)
            Map response = [field: id, description: ""]

            if (description) {
                response.description = description
            }

            render (response as JSON)
        } else {
            render (status: 400, text: "no field provided")
        }
    }

    /**
     * Provides a human-readable version of the Biocache /ws/index/fields JSON data.
     * Allows filtering and paginating of fields.
     *
     * @return
     */
    def fields() {
        List fields = biocacheService.getAllFields()
        params.max = params.max ?: 10
        params.order = params.order ?: "ASC"
        params.sort = params.sort ?: "name"
        params.filter = params.filter ?: ""

        if (params.filter) {
            def fld = "name" // default
            def val = params.filter
            def parts = val.split(":") // allow SOLR style: &filter=foo:bar

            if (parts.size() == 2) {
                fld = parts[0]
                val = parts[1]
                fields = fields.findAll() { it[fld] ==~ /${val}/  }
            } else {
                fields = fields.findAll() { Map it ->
                    it.values().join(" ").find(/${val}/) // search in any property
                }
            }
        }

        if (params.dwc) {
            fields = fields.findAll() { it.dwcTerm }
        }

        render (view: "fields", model: [
                fields: utilityService.paginateWrapper(fields, params),
                fieldsMax: fields.size()
        ])
    }
}
