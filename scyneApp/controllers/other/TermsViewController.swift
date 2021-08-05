//
//  TermsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 7/14/21.
//

import UIKit
import SafariServices

class TermsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private let introText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "scyne terms and conditions"
        return label
    }()
    
    private let effectiveDateText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "effective July 14 2021"
        return label
    }()
    
    private let agreementToTermsTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "AgreementTo Terms"
        return label
    }()
    
    
    private let agreementToTermsText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "These Terms and Conditions constitute a legally binding agreement made between you, whether personally or on behalf of an entity ('you') and Scyne ('we,' 'us' or 'our']), concerning your access to and use of the Scyne app as well as any other media form, media channel, mobile website or mobile application related, linked, or otherwise connected thereto (collectively, Scyne).\n\nYou agree that by accessing the app, you have read, understood, and agree to be bound by all of these Terms and Conditions. If you do not agree with all of these Terms and Conditions, then you are expressly prohibited from using the Site and you must discontinue use immediately.\n\n We reserve the right, in our sole discretion, to make changes or modifications to these Terms and Conditions at any time and for any reason.\n\n We will alert you about any changes by updating the “Last updated” date of these Terms and Conditions, and you waive any right to receive specific notice of each such change.\n\nIt is your responsibility to periodically review these Terms and Conditions to stay informed of updates. You will be subject to, and will be deemed to have been made aware of and to have accepted, the changes in any revised Terms and Conditions by your continued use of the app after the date such revised Terms and Conditions are posted.\n\nThe information provided on the Site is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country.\n\n Accordingly, those persons who choose to access the app from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.\n\n [The app is intended for users who are at least 13 years of age.] All users who are minors in the jurisdiction in which they reside (generally under the age of 18) must have the permission of, and be directly supervised by, their parent or guardian to use the Site. If you are a minor, you must have your parent or guardian read and agree to these Terms and Conditions prior to you using the App."
        return label
    }()
    
    private let intellectualPropertyRightsTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Intellectual Property Rights"
        return label
    }()
    
    private let intectualPropertyText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.text = "Unless otherwise indicated, the app is our proprietary property and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics on the Site (collectively, the “Content”) and the trademarks, service marks, and logos contained therein (the “Marks”) are owned or controlled by us or licensed to us, and are protected by copyright and trademark laws and various other intellectual property rights and unfair competition laws of the United States, foreign jurisdictions, and international conventions.\n\nThe Content and the Marks are provided on the app “AS IS” for your information and personal use only. Except as expressly provided in these Terms and Conditions, no part of the app and no Content or Marks may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission.\n\nProvided that you are eligible to use the app, you are granted a limited license to access and use the app and to download or print a copy of any portion of the Content to which you have properly gained access solely for your personal, non-commercial use. We reserve all rights not expressly granted to you in and to the app, the Content and the Marks."
        return label
    }()
    
    private let userRepresentationTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "User Representation"
        return label
    }()
    
    private let userRepresentationText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.text = "By using the Site, you represent and warrant that:\n[(1) all registration information you submit will be true, accurate, current, and complete; (2) you will maintain the accuracy of such information and promptly update such registration information as necessary;]\n(3) you have the legal capacity and you agree to comply with these Terms and Conditions;\n[(4) you are not under the age of 13;]\n(5) not a minor in the jurisdiction in which you reside [, or if a minor, you have received parental permission to use the Site];\n(6) you will not access the Site through automated or non-human means, whether through a bot, script, or otherwise;\n(7) you will not use the Site for any illegal or unauthorized purpose;\n(8) your use of the Site will not violate any applicable law or regulation.\nIf you provide any information that is untrue, inaccurate, not current, or incomplete, we have the right to suspend or terminate your account and refuse any and all current or future use of the Site (or any portion thereof)."
        return label
    }()
    
    private let restictedActivitiesTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Restricted Activities"
        return label
    }()
    
    private let restictedActivitiesText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.numberOfLines = 0
        label.text = "You may not access or use the Site for any purpose other than that for which we make the Site available. The Site may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us.\nAs a user of the Site, you agree not to:\n1.systematically retrieve data or other content from the Site to create or compile, directly or indirectly, a collection, compilation, database, or directory without written permission from us.\n2.make any unauthorized use of the Site, including collecting usernames and/or email addresses of users by electronic or other means for the purpose of sending unsolicited email, or creating user accounts by automated means or under false pretenses.\n3.use a buying agent or purchasing agent to make purchases on the Site.\n4.use the Site to advertise or offer to sell goods and services.\n5.circumvent, disable, or otherwise interfere with security-related features of the Site, including features that prevent or restrict the use or copying of any Content or enforce limitations on the use of the Site and/or the Content contained therein.\n6.engage in unauthorized framing of or linking to the Site.\n7.trick, defraud, or mislead us and other users, especially in any attempt to learn sensitive account information such as user passwords\n8.make improper use of our support services or submit false reports of abuse or misconduct.\n9.engage in any automated use of the system, such as using scripts to send comments or messages, or using any data mining, robots, or similar data gathering and extraction tools.\n10.interfere with, disrupt, or create an undue burden on the Site or the networks or services connected to the Site.\n11.attempt to impersonate another user or person or use the username of another user.\n12.sell or otherwise transfer your profile.\n13.use any information obtained from the Site in order to harass, abuse, or harm another person.\n15.use the Site as part of any effort to compete with us or otherwise use the Site and/or the Content for any revenue-generating endeavor or commercial enterprise.\n16.decipher, decompile, disassemble, or reverse engineer any of the software comprising or in any way making up a part of the Site.\n17.attempt to bypass any measures of the Site designed to prevent or restrict access to the Site, or any portion of the Site.\n18.harass, annoy, intimidate, or threaten any of our employees or agents engaged in providing any portion of the Site to you.\n19.delete the copyright or other proprietary rights notice from any Content.\n20.copy or adapt the Site’s software, including but not limited to Flash, PHP, HTML, JavaScript, or other code.\n21.upload or transmit (or attempt to upload or to transmit) viruses, Trojan horses, or other material, including excessive use of capital letters and spamming (continuous posting of repetitive text), that interferes with any party’s uninterrupted use and enjoyment of the Site or modifies, impairs, disrupts, alters, or interferes with the use, features, functions, operation, or maintenance of the Site.\n22.upload or transmit (or attempt to upload or to transmit) any material that acts as a passive or active information collection or transmission mechanism, including without limitation, clear graphics interchange formats (“gifs”), 1×1 pixels, web bugs, cookies, or other similar devices (sometimes referred to as “spyware” or “passive collection mechanisms” or “pcms”).\n23.except as may be the result of standard search engine or Internet browser usage, use, launch, develop, or distribute any automated system, including without limitation, any spider, robot, cheat utility, scraper, or offline reader that accesses the Site, or using or launching any unauthorized script or other software.\n24.disparage, tarnish, or otherwise harm, in our opinion, us and/or the Site.\n25.use the Site in a manner inconsistent with any applicable laws or regulations."
        return label
    }()
    
    private let userGeneratedContributions: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "User Generated Contributions"
        return label
    }()
    
    private let userGeneratedContributionsText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "The app may invite you to chat, contribute to, or participate in blogs, message boards, online forums, and other functionality, and may provide you with the opportunity to create, submit, post, display, transmit, perform, publish, distribute, or broadcast content and materials to us or on the app, including but not limited to text, writings, video, audio, photographs, graphics, comments, suggestions, or personal information or other material (collectively, “Contributions”).\nContributions may be viewable by other users of the app and through third-party websites. As such, any Contributions you transmit may be treated as non-confidential and non-proprietary. When you create or make available any Contributions, you thereby represent and warrant that:\n\n1.the creation, distribution, transmission, public display, or performance, and the accessing, downloading, or copying of your Contributions do not and will not infringe the proprietary rights, including but not limited to the copyright, patent, trademark, trade secret, or moral rights of any third party.\n2.you are the creator and owner of or have the necessary licenses, rights, consents, releases, and permissions to use and to authorize us, the app, and other users of the app to use your Contributions in any manner contemplated by the Site and these Terms and Conditions.\n3.you have the written consent, release, and/or permission of each and every identifiable individual person in your Contributions to use the name or likeness of each and every such identifiable individual person to enable inclusion and use of your Contributions in any manner contemplated by the app and these Terms and Conditions.\n4.your Contributions are not false, inaccurate, or misleading.\n5.your Contributions are not unsolicited or unauthorized advertising, promotional materials, pyramid schemes, chain letters, spam, mass mailings, or other forms of solicitation.\n6.your Contributions are not obscene, lewd, lascivious, filthy, violent, harassing, libelous, slanderous, or otherwise objectionable (as determined by us).\n8.your Contributions do not ridicule, mock, disparage, intimidate, or abuse anyone.\n9.your Contributions do not advocate the violent overthrow of any government or incite, encourage, or threaten physical harm against another.\n10.your Contributions do not violate any applicable law, regulation, or rule.\n11.your Contributions do not violate the privacy or publicity rights of any third party.\n12.your Contributions do not contain any material that solicits personal information from anyone under the age of 18 or exploits people under the age of 18 in a sexual or violent manner.\n13.your Contributions do not violate any federal or state law concerning child pornography, or otherwise intended to protect the health or well-being of minors;\n14.your Contributions do not include any offensive comments that are connected to race, national origin, gender, sexual preference, or physical handicap.\n15.your Contributions do not otherwise violate, or link to material that violates, any provision of these Terms and Conditions, or any applicable law or regulation.\n16.Any use of the app in violation of the foregoing violates these Terms and Conditions and may result in, among other things, termination or suspension of your rights to use the app."
        return label
    }()
    
    private let mobileApplicationLicenseTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Mobile Application License"
        return label
    }()
    
    
    private let mobileApplicationLicenseText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "If you access the Site via a mobile application, then we grant you a revocable, non-exclusive, non-transferable, limited right to install and use the mobile application on wireless electronic devices owned or controlled by you, and to access and use the mobile application on such devices strictly in accordance with the terms and conditions of this mobile application license contained in these Terms and Conditions.\nYou shall not:\n(1) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the application;\n(2) make any modification, adaptation, improvement, enhancement, translation, or derivative work from the application;\n(3) violate any applicable laws, rules, or regulations in connection with your access or use of the application;\n(4) remove, alter, or obscure any proprietary notice (including any notice of copyright or trademark) posted by us or the licensors of the application;\n(5) use the application for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended;\n(6) make the application available over a network or other environment permitting access or use by multiple devices or users at the same time;\n(7) use the application for creating a product, service, or software that is, directly or indirectly, competitive with or in any way a substitute for the application;\n(8) use the application to send automated queries to any website or to send any unsolicited commercial e-mail;\n(9) use any proprietary information or any of our interfaces or our other intellectual property in the design, development, manufacture, licensing, or distribution of any applications, accessories, or devices for use with the application"
        return label
    }()
    
    private let thirdPartyTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Third-party website and content"
        return label
    }()
    
    private let thirdPartyText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "The app may contain (or you may be sent via the Site) links to other websites (“Third-Party Websites”) as well as articles, photographs, text, graphics, pictures, designs, music, sound, video, information, applications, software, and other content or items belonging to or originating from third parties (“Third-Party Content”).\nSuch Third-Party Websites and Third-Party Content are not investigated, monitored, or checked for accuracy, appropriateness, or completeness by us, and we are not responsible for any Third-Party Websites accessed through the app or any Third-Party Content posted on, available through, or installed from the app, including the content, accuracy, offensiveness, opinions, reliability, privacy practices, or other policies of or contained in the Third-Party Websites or the Third-Party Content.\nInclusion of, linking to, or permitting the use or installation of any Third-Party Websites or any Third-Party Content does not imply approval or endorsement thereof by us. If you decide to leave the Site and access the Third-Party Websites or to use or install any Third-Party Content, you do so at your own risk, and you should be aware these Terms and Conditions no longer govern.\nYou should review the applicable terms and policies, including privacy and data gathering practices, of any website to which you navigate from the app or relating to any applications you use or install from the app. Any purchases you make through Third-Party Websites will be through other websites and from other companies, and we take no responsibility whatsoever in relation to such purchases which are exclusively between you and the applicable third party.\nYou agree and acknowledge that we do not endorse the products or services offered on Third-Party Websites and you shall hold us harmless from any harm caused by your purchase of such products or services. Additionally, you shall hold us harmless from any losses sustained by you or harm caused to you relating to or resulting in any way from any Third-Party Content or any contact with Third-Party Websites."
        return label
    }()
    
    private let advertisersTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Advertisers"
        return label
    }()
    
    private let advertisersText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "We allow advertisers to display their advertisements and other information in certain areas of the app, such as sidebar advertisements or banner advertisements. If you are an advertiser, you shall take full responsibility for any advertisements you place on the Site and any services provided on the app or products sold through those advertisements.\nFurther, as an advertiser, you warrant and represent that you possess all rights and authority to place advertisements on the app, including, but not limited to, intellectual property rights, publicity rights, and contractual rights.\n[As an advertiser, you agree that such advertisements are subject to our Digital Millennium Copyright Act (“DMCA”) Notice and Policy provisions as described below, and you understand and agree there will be no refund or other compensation for DMCA takedown-related issues.] We simply provide the space to place such advertisements, and we have no other relationship with advertisers."
        return label
    }()
    
    private let appManagementTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "App management"
        return label
    }()
    
    private let appManagementText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text =  "We reserve the right, but not the obligation, to:\n(1) monitor the Site for violations of these Terms and Conditions;\n(2) take appropriate legal action against anyone who, in our sole discretion, violates the law or these Terms and Conditions, including without limitation, reporting such user to law enforcement authorities;\n(3) in our sole discretion and without limitation, refuse, restrict access to, limit the availability of, or disable (to the extent technologically feasible) any of your Contributions or any portion thereof;\n(4) in our sole discretion and without limitation, notice, or liability, to remove from the Site or otherwise disable all files and content that are excessive in size or are in any way burdensome to our systems;\n(5) otherwise manage the Site in a manner designed to protect our rights and property and to facilitate the proper functioning of the Site."
        return label
    }()
    
    private let copyrightTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "copyright infringement"
        return label
    }()
    
    private let copyrightText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "We respect the intellectual property rights of others. If you believe that any material available on or through the app infringes upon any copyright you own or control, please immediately notify us using the contact information provided (scyneskateapp@gmail.com). The user will be contacted and addressed."
        return label
    }()
    
    private let termsTerminationTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "TERMS AND TERMINATION"
        return label
    }()
    
    private let termTerminationText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "These Terms and Conditions shall remain in full force and effect while you use the app. WITHOUT LIMITING ANY OTHER PROVISION OF THESE TERMS AND CONDITIONS, WE RESERVE THE RIGHT TO, IN OUR SOLE DISCRETION AND WITHOUT NOTICE OR LIABILITY, DENY ACCESS TO AND USE OF THE SITE (INCLUDING BLOCKING CERTAIN IP ADDRESSES), TO ANY PERSON FOR ANY REASON OR FOR NO REASON, INCLUDING WITHOUT LIMITATION FOR BREACH OF ANY REPRESENTATION, WARRANTY, OR COVENANT CONTAINED IN THESE TERMS AND CONDITIONS OR OF ANY APPLICABLE LAW OR REGULATION. WE MAY TERMINATE YOUR USE OR PARTICIPATION IN THE SITE OR DELETE [YOUR ACCOUNT AND] ANY CONTENT OR INFORMATION THAT YOU POSTED AT ANY TIME, WITHOUT WARNING, IN OUR SOLE DISCRETION.\n\nIf we terminate or suspend your account for any reason, you are prohibited from registering and creating a new account under your name, a fake or borrowed name, or the name of any third party, even if you may be acting on behalf of the third party.\n\nIn addition to terminating or suspending your account, we reserve the right to take appropriate legal action, including without limitation pursuing civil, criminal, and injunctive redress."
        return label
    }()
    
    private let modificationsInteruptionsTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "TERMS AND TERMINATION"
        return label
    }()
    
    private let termsTerminationText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "We reserve the right to change, modify, or remove the contents of the Site at any time or for any reason at our sole discretion without notice. However, we have no obligation to update any information on our app. We also reserve the right to modify or discontinue all or part of the Site without notice at any time.\n\nWe will not be liable to you or any third party for any modification, price change, suspension, or discontinuance of the Site.\n\nWe cannot guarantee the app will be available at all times. We may experience hardware, software, or other problems or need to perform maintenance related to the Site, resulting in interruptions, delays, or errors.\n\nWe reserve the right to change, revise, update, suspend, discontinue, or otherwise modify the Site at any time or for any reason without notice to you. You agree that we have no liability whatsoever for any loss, damage, or inconvenience caused by your inability to access or use the app during any downtime or discontinuance of the Site.\n\nNothing in these Terms and Conditions will be construed to obligate us to maintain and support the Site or to supply any corrections, updates, or releases in connection therewith."
        return label
    }()
    
    private let governingLawTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Governing law"
        return label
    }()
    
    private let governingLawText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "These Terms and Conditions and your use of the app are governed by and construed in accordance with the laws of the State of Texas applicable to agreements made and to be entirely performed within the State/Commonwealth of Texas, without regard to its conflict of law principles."
        return label
    }()
    
    private let disclaimerTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Disclaimer"
        return label
    }()
    
    private let disclaimerText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = " THE APP IS PROVIDED ON AN AS-IS AND AS-AVAILABLE BASIS. YOU AGREE THAT YOUR USE OF THE SITE AND OUR SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE APP AND YOUR USE THEREOF, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE MAKE NO WARRANTIES OR REPRESENTATIONS ABOUT THE ACCURACY OR COMPLETENESS OF THE APPS’S CONTENT OR THE CONTENT OF ANY WEBSITES LINKED TO THE APP AND WE WILL ASSUME NO LIABILITY OR RESPONSIBILITY FOR ANY (1) ERRORS, MISTAKES, OR INACCURACIES OF CONTENT AND MATERIALS, (2) PERSONAL INJURY OR PROPERTY DAMAGE, OF ANY NATURE WHATSOEVER, RESULTING FROM YOUR ACCESS TO AND USE OF THE SITE, (3) ANY UNAUTHORIZED ACCESS TO OR USE OF OUR SECURE SERVERS AND/OR ANY AND ALL PERSONAL INFORMATION AND/OR FINANCIAL INFORMATION STORED THEREIN, (4) ANY INTERRUPTION OR CESSATION OF TRANSMISSION TO OR FROM THE APP, (5) ANY BUGS, VIRUSES, TROJAN HORSES, OR THE LIKE WHICH MAY BE TRANSMITTED TO OR THROUGH THE SITE BY ANY THIRD PARTY, AND/OR (6) ANY ERRORS OR OMISSIONS IN ANY CONTENT AND MATERIALS OR FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF THE USE OF ANY CONTENT POSTED, TRANSMITTED, OR OTHERWISE MADE AVAILABLE VIA THE APP. WE DO NOT WARRANT, ENDORSE, GUARANTEE, OR ASSUME RESPONSIBILITY FOR ANY PRODUCT OR SERVICE ADVERTISED OR OFFERED BY A THIRD PARTY THROUGH THE SITE, ANY HYPERLINKED WEBSITE, OR ANY WEBSITE OR MOBILE APPLICATION FEATURED IN ANY BANNER OR OTHER ADVERTISING, AND WE WILL NOT BE A PARTY TO OR IN ANY WAY BE RESPONSIBLE FOR MONITORING ANY TRANSACTION BETWEEN YOU AND ANY THIRD-PARTY PROVIDERS OF PRODUCTS OR SERVICES.\n\nAS WITH THE PURCHASE OF A PRODUCT OR SERVICE THROUGH ANY MEDIUM OR IN ANY ENVIRONMENT, YOU SHOULD USE YOUR BEST JUDGMENT AND EXERCISE CAUTION WHERE APPROPRIATE."
        return label
    }()
    
    private let limitationsLiabilityTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Limitations of liability"
        return label
    }()
    
    private let limitationsLiabilityText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE APP, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\n\n[NOTWITHSTANDING ANYTHING TO THE CONTRARY CONTAINED HEREIN, OUR LIABILITY TO YOU FOR ANY CAUSE WHATSOEVER AND REGARDLESS OF THE FORM OF THE ACTION, WILL AT ALL TIMES BE LIMITED TO [THE LESSER OF] [THE AMOUNT PAID, IF ANY, BY YOU TO US DURING THE [_________] MONTH PERIOD PRIOR TO ANY CAUSE OF ACTION ARISING [OR] [$_________]. CERTAIN STATE LAWS DO NOT ALLOW LIMITATIONS ON IMPLIED WARRANTIES OR THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES.\n\nIF THESE LAWS APPLY TO YOU, SOME OR ALL OF THE ABOVE DISCLAIMERS OR LIMITATIONS MAY NOT APPLY TO YOU, AND YOU MAY HAVE ADDITIONAL RIGHTS.]"
        return label
    }()
    
    private let userDataTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "User Data"
        return label
    }()
    
    private let userDataText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "We will maintain certain data that you transmit to the App for the purpose of managing the App, as well as data relating to your use of the App. Although we perform regular routine backups of data, you are solely responsible for all data that you transmit or that relates to any activity you have undertaken using the App.\n\nYou agree that we shall have no liability to you for any loss or corruption of any such data, and you hereby waive any right of action against us arising from any such loss or corruption of such data."
        return label
    }()
    
    private let commTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Electronic communications, transactions and signitures"
        return label
    }()
    
    private let commText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "Visiting the Site, sending us emails, and completing online forms constitute electronic communications. You consent to receive electronic communications, and you agree that all agreements, notices, disclosures, and other communications we provide to you electronically, via email and on the Site, satisfy any legal requirement that such communication be in writing.\n\nYOU HEREBY AGREE TO THE USE OF ELECTRONIC SIGNATURES, CONTRACTS, ORDERS, AND OTHER RECORDS, AND TO ELECTRONIC DELIVERY OF NOTICES, POLICIES, AND RECORDS OF TRANSACTIONS INITIATED OR COMPLETED BY US OR VIA THE SITE.\n\nYou hereby waive any rights or requirements under any statutes, regulations, rules, ordinances, or other laws in any jurisdiction which require an original signature or delivery or retention of non-electronic records, or to payments or the granting of credits by any means other than electronic means."
        return label
    }()
    
    private let miscTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "MISCELLANEOUS"
        return label
    }()
    
    private let miscText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "These Terms and Conditions and any policies or operating rules posted by us on the Site constitute the entire agreement and understanding between you and us. Our failure to exercise or enforce any right or provision of these Terms and Conditions shall not operate as a waiver of such right or provision.\n\nThese Terms and Conditions operate to the fullest extent permissible by law. We may assign any or all of our rights and obligations to others at any time. We shall not be responsible or liable for any loss, damage, delay, or failure to act caused by any cause beyond our reasonable control.\n\nIf any provision or part of a provision of these Terms and Conditions is determined to be unlawful, void, or unenforceable, that provision or part of the provision is deemed severable from these Terms and Conditions and does not affect the validity and enforceability of any remaining provisions.\n\nThere is no joint venture, partnership, employment or agency relationship created between you and us as a result of these Terms and Conditions or use of the Site. You agree that these Terms and Conditions will not be construed against us by virtue of having drafted them.\n\nYou hereby waive any and all defenses you may have based on the electronic form of these Terms and Conditions and the lack of signing by the parties hereto to execute these Terms and Conditions."
        return label
    }()
    
    private let contactTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Contact us"
        return label
    }()
    
    private let contactText: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "contact us at scyneskateapp@gmail.com"
        return label
    }()
    
    private let privacyTitle: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "To view scyne privacy policy click link below"
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("privacy Policy", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "terms and conditions"
        
        view.addSubview(scrollView)
        view.addSubview(button)
        view.addSubview(privacyTitle)
        button.addTarget(self, action: #selector(didTapPP), for: .touchUpInside)
        setUpScrollView()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 10, width: view.width-40, height: ((view.height/4)*3) - 30)
        privacyTitle.frame = CGRect(x: 20, y: scrollView.bottom + 7, width: view.width - 40, height: 20)
        button.frame = CGRect(x: 30, y: privacyTitle.bottom + 7, width: view.width - 60, height: 20)
    }
    
    private func setUpScrollView() {
        scrollView.contentSize = CGSize(width: view.width - 40, height: (16020 + 220))
        
        scrollView.addSubview(introText)
        introText.frame = CGRect(x: 25, y: introText.top + 20, width: view.width - 80, height: 20)
        scrollView.addSubview(effectiveDateText)
        effectiveDateText.frame = CGRect(x: 25, y: introText.bottom + 15, width: view.width - 80, height: 20)
        scrollView.addSubview(agreementToTermsTitle)
        agreementToTermsTitle.frame = CGRect(x: 25, y: effectiveDateText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(agreementToTermsText)
        agreementToTermsText.frame = CGRect(x: 25, y: agreementToTermsTitle.bottom + 10, width: view.width - 80, height: 1440)
        scrollView.addSubview(intellectualPropertyRightsTitle)
        intellectualPropertyRightsTitle.frame = CGRect(x: 25, y: agreementToTermsText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(intectualPropertyText)
        intectualPropertyText.frame = CGRect(x: 25, y: intellectualPropertyRightsTitle.bottom + 10, width: view.width - 80, height: 820)
        scrollView.addSubview(userRepresentationTitle)
        userRepresentationTitle.frame = CGRect(x: 25, y: intectualPropertyText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(userRepresentationText)
        userRepresentationText.frame = CGRect(x: 25, y: userRepresentationTitle.bottom + 10, width: view.width - 80, height: 670)
        scrollView.addSubview(restictedActivitiesTitle)
        restictedActivitiesTitle.frame = CGRect(x: 25, y: userRepresentationText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(restictedActivitiesText)
        restictedActivitiesText.frame = CGRect(x: 25, y: restictedActivitiesTitle.bottom + 10, width: view.width - 80, height: 2210)
        scrollView.addSubview(userGeneratedContributions)
        userGeneratedContributions.frame = CGRect(x: 25, y: restictedActivitiesText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(userGeneratedContributionsText)
        userGeneratedContributionsText.frame = CGRect(x: 25, y: userGeneratedContributions.bottom + 10, width: view.width-80, height: 1850)
        scrollView.addSubview(mobileApplicationLicenseTitle)
        mobileApplicationLicenseTitle.frame = CGRect(x: 25, y: userGeneratedContributionsText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(mobileApplicationLicenseText)
        mobileApplicationLicenseText.frame = CGRect(x: 25, y: mobileApplicationLicenseTitle.bottom + 10, width: view.width - 80, height: 1000)
        scrollView.addSubview(thirdPartyTitle)
        thirdPartyTitle.frame = CGRect(x: 25, y: mobileApplicationLicenseText.bottom + 20, width: view.width - 80, height: 20)
        scrollView.addSubview(thirdPartyText)
        thirdPartyText.frame = CGRect(x: 25, y: thirdPartyTitle.bottom + 10, width: view.width - 80, height: 1100)
        scrollView.addSubview(advertisersTitle)
        advertisersTitle.frame = CGRect(x: 25, y: thirdPartyText.bottom + 30, width: view.width - 80, height: 20)
        scrollView.addSubview(advertisersText)
        advertisersText.frame = CGRect(x: 25, y: advertisersTitle.bottom + 10, width: view.width - 80, height: 600)
        scrollView.addSubview(appManagementTitle)
        appManagementTitle.frame = CGRect(x: 25, y: advertisersText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(appManagementText)
        appManagementText.frame = CGRect(x: 25, y: appManagementTitle.bottom + 10, width: view.width - 80, height: 580)
        scrollView.addSubview(copyrightTitle)
        copyrightTitle.frame = CGRect(x: 25, y: appManagementText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(copyrightText)
        copyrightText.frame = CGRect(x: 25, y: copyrightTitle.bottom + 10, width: view.width - 80, height: 160)
        scrollView.addSubview(termsTerminationTitle)
        termsTerminationTitle.frame = CGRect(x: 25, y: copyrightText.bottom + 35, width: view.width - 80, height: 20)
        scrollView.addSubview(termsTerminationText)
        termsTerminationText.frame = CGRect(x: 25, y: termsTerminationTitle.bottom + 10, width: view.width - 80, height: 800)
        scrollView.addSubview(governingLawTitle)
        governingLawTitle.frame = CGRect(x: 25, y: termsTerminationText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(governingLawText)
        governingLawText.frame = CGRect(x: 25, y: governingLawTitle.bottom + 10, width: view.width - 80, height: 240)
        scrollView.addSubview(disclaimerTitle)
        disclaimerTitle.frame = CGRect(x: 25, y: governingLawText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(disclaimerText)
        disclaimerText.frame = CGRect(x: 25, y: disclaimerTitle.bottom + 10, width: view.width - 80, height: 1320)
        scrollView.addSubview(limitationsLiabilityTitle)
        limitationsLiabilityTitle.frame = CGRect(x: 25, y: disclaimerText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(limitationsLiabilityText)
        limitationsLiabilityText.frame = CGRect(x: 25, y: limitationsLiabilityTitle.bottom + 10, width: view.width - 80, height: 730)
        scrollView.addSubview(userDataTitle)
        userDataTitle.frame = CGRect(x: 25, y: limitationsLiabilityText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(userDataText)
        userDataText.frame = CGRect(x: 25, y: userDataTitle.bottom + 10, width: view.width - 80, height: 300)
        scrollView.addSubview(commTitle)
        commTitle.frame = CGRect(x: 25, y: userDataText.bottom + 10, width: view.width - 80, height: 50)
        scrollView.addSubview(commText)
        commText.frame = CGRect(x: 25, y: commTitle.bottom + 10, width: view.width - 80, height: 600)
        scrollView.addSubview(miscTitle)
        miscTitle.frame = CGRect(x: 25, y: commText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(miscText)
        miscText.frame =  CGRect(x: 25, y: miscTitle.bottom + 10, width: view.width - 80, height: 800)
        scrollView.addSubview(contactTitle)
        contactTitle.frame = CGRect(x: 25, y: miscText.bottom + 10, width: view.width - 80, height: 20)
        scrollView.addSubview(contactText)
        contactText.frame = CGRect(x: 25, y: contactTitle.bottom + 10, width: view.width - 80, height: 50)
    }
    
    @objc func didTapPP() {
        let website = "https://www.privacypolicies.com/live/c487ac90-8f69-41b3-9327-d9e9ed7aa18c"
        let result = urlOpener.shared.verifyUrl(urlString: website)
        if result == true {
            if let url = URL(string: website ) {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true)
            }
        } else {
            print("cant open url")
            let ac = UIAlertController(title: "invalid url", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(ac, animated: true)
        }
        
    }

}
