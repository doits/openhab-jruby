Feature:  thing
  Rule languages supports interacting with things

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And feature 'openhab-binding-astro' installed
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |

  Scenario: Things method provides access to all things.
    Given code in a rules file
      """
      things.each { |thing| logger.info("Thing: #{thing.uid}")}
      """
    When I deploy the rules file
    Then It should log 'Thing: astro:sun:home' within 5 seconds

  Scenario: Things support [] lookup
    Given code in a rules file
      """
      logger.info("Thing: #{things['astro:sun:home'].uid}")
      """
    When I deploy the rules file
    Then It should log 'Thing: astro:sun:home' within 5 seconds

  Scenario: Things support [] lookup using a ThingUID
    Given code in a rules file
      """
      logger.info("Thing: #{things[org.openhab.core.thing.ThingUID.new('astro:sun:home')].uid}")
      """
    When I deploy the rules file
    Then It should log 'Thing: astro:sun:home' within 5 seconds

  Scenario: ThingUID#inspect logs the full UID as string
    Given code in a rules file
      """
      logger.info("Thing: #{org.openhab.core.thing.ThingUID.new('astro:sun:home').inspect}")
      """
    When I deploy the rules file
    Then It should log 'Thing: astro:sun:home' within 5 seconds

  Scenario: ThingUID#== works against a regular string
    Given code in a rules file
      """
      logger.info("Is equal: #{org.openhab.core.thing.ThingUID.new('astro:sun:home') == 'astro:sun:home'}")
      """
    When I deploy the rules file
    Then It should log 'Is equal: true' within 5 seconds

  Scenario: String#== works against a ThingUID (using ThingUID#to_str)
    Given code in a rules file
      """
      logger.info("Is equal: #{'astro:sun:home' == org.openhab.core.thing.ThingUID.new('astro:sun:home')}")
      """
    When I deploy the rules file
    Then It should log 'Is equal: true' within 5 seconds

  Scenario: ThingUID#binding_id returns the correct value
    Given code in a rules file
      """
      logger.info("Binding: #{org.openhab.core.thing.ThingUID.new('astro:sun:home').binding_id}$")
      """
    When I deploy the rules file
    Then It should log 'Binding: astro$' within 5 seconds

  Scenario Outline: Rule supports thing status changes for changed and updated
    Given a deployed rule:
      """
      rule 'Execute rule when thing is <trigger>' do
        <trigger> things['astro:sun:home']
        run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It should log 'Thing astro:sun:home status <trigger> to UNINITIALIZED (DISABLED)' within 5 seconds
    Examples:
      | trigger |
      | changed |
      | updated |

  Scenario Outline: Rule supports thing status changes and updates with specific to states
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed' do
        <trigger> things['astro:sun:home'], :to => <state>
        run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It <should> log 'Thing astro:sun:home status <trigger> to UNINITIALIZED (DISABLED)' within 5 seconds
    Examples:
      | state          | trigger | should     |
      | :uninitialized | changed | should     |
      | :unknown       | changed | should not |
      | :uninitialized | updated | should     |
      | :unknown       | updated | should not |

  Scenario Outline: Rule supports thing status changes with specific from states
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed' do
        changed things['astro:sun:home'], :from => <state>
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It <should> log 'Thing astro:sun:home status changed to UNINITIALIZED' within 5 seconds
    Examples:
      | state    | should     |
      | :online  | should     |
      | :unknown | should not |

  Scenario Outline: Rule supports thing status changes with specific from and to states
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed' do
        changed things['astro:sun:home'], :from => <from_state>, :to => <to_state>
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It <should> log 'Thing astro:sun:home status changed to UNINITIALIZED' within 5 seconds
    Examples:
      | from_state | to_state       | should     |
      | :online    | :uninitialized | should     |
      | :unknown   | :uninitialized | should not |

  Scenario Outline: Rule supports thing status changes with duration
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed for 10 seconds' do
        changed things['astro:sun:home'], :to => :uninitialized, for: 10.seconds
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    And thing "astro:sun:home" is enabled
    When thing "astro:sun:home" is disabled
    Then It should log 'Thing astro:sun:home status changed to UNINITIALIZED' within 15 seconds

  Scenario Outline: Rule supports thing status changes with duration
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed for 20 seconds' do
        changed things['astro:sun:home'], :to => :uninitialized, for: 20.seconds
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    And thing "astro:sun:home" is enabled
    When thing "astro:sun:home" is disabled
    Then if I wait 5 seconds
    And thing "astro:sun:home" is enabled
    Then It should not log 'Thing astro:sun:home status changed to UNINITIALIZED' within 20 seconds

  Scenario Outline: Rule supports boolean thing status methods
    Given thing "astro:sun:home" is <enable>
    And if I wait 5 seconds
    And code in a rules file
      """
      logger.info("Thing is <method> #{things['astro:sun:home'].<method>}")
      """
    When I deploy the rules file
    Then It should log 'Thing is <method> <result>' within 20 seconds
    Examples:
      | method         | enable   | result |
      | online?        | enabled  | true   |
      | online?        | disabled | false  |
      | uninitialized? | disabled | true   |
      | uninitialized? | enabled  | false  |

  Scenario: Channel returns its linked item
    Given feature 'openhab-binding-astro' installed
    And items:
      | type | name |
      | String | PhaseName |
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |
    And linked:
      | item | channel |
      | PhaseName | astro:sun:home:phase#name |
    And code in a rules file
      """
      logger.info("Item: #{things['astro:sun:home'].channels['phase#name'].item.name}")
      """
    When I deploy the rules file
    Then It should log "Item: PhaseName" within 5 seconds

  Scenario: Channel returns its thing
    Given feature 'openhab-binding-astro' installed
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |
    And code in a rules file
      """
      logger.info("Thing: #{things['astro:sun:home'].channels['phase#name'].thing.uid}")
      """
    When I deploy the rules file
    Then It should log "Thing: astro:sun:home" within 5 seconds
