#!/usr/bin/env python3
"""
Wazuh Detection Rule Validator
Validates custom detection rules for syntax, structure, and MITRE ATT&CK mapping
"""

import xml.etree.ElementTree as ET
import sys
import os
import re
from pathlib import Path
from typing import List, Dict, Set, Tuple

# MITRE ATT&CK technique ID pattern
MITRE_PATTERN = re.compile(r'^T\d{4}(\.\d{3})?$')

# Valid MITRE ATT&CK tactics
VALID_TACTICS = {
    'reconnaissance', 'resource-development', 'initial-access', 
    'execution', 'persistence', 'privilege-escalation',
    'defense-evasion', 'credential-access', 'discovery',
    'lateral-movement', 'collection', 'command-and-control',
    'exfiltration', 'impact'
}

class RuleValidator:
    def __init__(self, rules_file: str):
        self.rules_file = rules_file
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.rule_ids: Set[int] = set()
        self.rules_validated = 0
        
    def validate(self) -> bool:
        """Main validation method"""
        print(f"Validating {self.rules_file}...")
        
        if not os.path.exists(self.rules_file):
            self.errors.append(f"File not found: {self.rules_file}")
            return False
            
        # Parse XML
        try:
            tree = ET.parse(self.rules_file)
            root = tree.getroot()
        except ET.ParseError as e:
            self.errors.append(f"XML parsing error: {e}")
            return False
            
        # Validate each rule
        for group in root.findall('.//group'):
            for rule in group.findall('rule'):
                self._validate_rule(rule)
                
        # Print results
        self._print_results()
        
        return len(self.errors) == 0
        
    def _validate_rule(self, rule: ET.Element):
        """Validate individual rule"""
        self.rules_validated += 1
        rule_id = rule.get('id')
        
        if not rule_id:
            self.errors.append("Rule missing ID attribute")
            return
            
        # Check rule ID format and duplicates
        try:
            rule_id_int = int(rule_id)
            if rule_id_int in self.rule_ids:
                self.errors.append(f"Duplicate rule ID: {rule_id}")
            self.rule_ids.add(rule_id_int)
            
            # Check ID range (custom rules should be 100000-199999)
            if not (100000 <= rule_id_int <= 199999):
                self.warnings.append(
                    f"Rule {rule_id}: ID outside recommended custom range (100000-199999)"
                )
        except ValueError:
            self.errors.append(f"Invalid rule ID format: {rule_id}")
            
        # Check level attribute
        level = rule.get('level')
        if not level:
            self.errors.append(f"Rule {rule_id}: Missing level attribute")
        else:
            try:
                level_int = int(level)
                if not (0 <= level_int <= 15):
                    self.errors.append(
                        f"Rule {rule_id}: Level {level} out of range (0-15)"
                    )
            except ValueError:
                self.errors.append(f"Rule {rule_id}: Invalid level format")
                
        # Check required elements
        self._check_required_elements(rule, rule_id)
        
        # Validate MITRE ATT&CK mapping
        self._validate_mitre_mapping(rule, rule_id)
        
        # Check description quality
        self._check_description(rule, rule_id)
        
        # Validate field patterns
        self._validate_patterns(rule, rule_id)
        
    def _check_required_elements(self, rule: ET.Element, rule_id: str):
        """Check for required XML elements"""
        description = rule.find('description')
        if description is None or not description.text:
            self.errors.append(f"Rule {rule_id}: Missing or empty description")
            
        # Check for detection logic (at least one condition)
        has_condition = any([
            rule.find('field') is not None,
            rule.find('regex') is not None,
            rule.find('match') is not None,
            rule.find('if_sid') is not None,
            rule.find('if_group') is not None
        ])
        
        if not has_condition:
            self.errors.append(
                f"Rule {rule_id}: No detection logic found (field, regex, match, etc.)"
            )
            
    def _validate_mitre_mapping(self, rule: ET.Element, rule_id: str):
        """Validate MITRE ATT&CK technique mapping"""
        mitre = rule.find('mitre')
        if mitre is None:
            self.warnings.append(f"Rule {rule_id}: No MITRE ATT&CK mapping")
            return
            
        technique_id = mitre.find('id')
        if technique_id is None or not technique_id.text:
            self.errors.append(f"Rule {rule_id}: MITRE mapping missing technique ID")
            return
            
        # Validate technique ID format
        if not MITRE_PATTERN.match(technique_id.text):
            self.errors.append(
                f"Rule {rule_id}: Invalid MITRE technique ID format: {technique_id.text}"
            )
            
        # Check for tactic in groups
        groups = rule.find('group')
        if groups is not None and groups.text:
            group_list = [g.strip() for g in groups.text.split(',') if g.strip()]
            has_tactic = any(
                g.replace('attack.', '') in VALID_TACTICS 
                for g in group_list if g.startswith('attack.')
            )
            if not has_tactic:
                self.warnings.append(
                    f"Rule {rule_id}: No MITRE tactic in group tags"
                )
        else:
            self.warnings.append(f"Rule {rule_id}: No group tags defined")
            
    def _check_description(self, rule: ET.Element, rule_id: str):
        """Check description quality"""
        description = rule.find('description')
        if description is not None and description.text:
            desc_text = description.text.strip()
            
            # Check minimum length
            if len(desc_text) < 20:
                self.warnings.append(
                    f"Rule {rule_id}: Description too short (<20 chars)"
                )
                
            # Check for meaningful content
            generic_phrases = ['suspicious', 'detected', 'found', 'activity']
            if not any(phrase in desc_text.lower() for phrase in generic_phrases):
                self.warnings.append(
                    f"Rule {rule_id}: Description may lack context"
                )
                
    def _validate_patterns(self, rule: ET.Element, rule_id: str):
        """Validate regex patterns and field names"""
        # Check regex syntax
        for regex in rule.findall('.//regex'):
            if regex.text:
                try:
                    re.compile(regex.text)
                except re.error as e:
                    self.errors.append(
                        f"Rule {rule_id}: Invalid regex pattern: {e}"
                    )
                    
        # Check PCRE2 syntax (basic validation)
        for pcre2 in rule.findall('.//pcre2'):
            if pcre2.text:
                # Basic PCRE2 validation
                if pcre2.text.count('(') != pcre2.text.count(')'):
                    self.warnings.append(
                        f"Rule {rule_id}: Unbalanced parentheses in PCRE2 pattern"
                    )
                    
        # Check field names are valid
        valid_field_prefixes = [
            'data.win.eventdata',
            'data.win.system',
            'data.audit',
            'syscheck',
            'predecoder'
        ]
        
        for field in rule.findall('.//field'):
            field_name = field.get('name')
            if field_name:
                if not any(field_name.startswith(prefix) for prefix in valid_field_prefixes):
                    self.warnings.append(
                        f"Rule {rule_id}: Unusual field name: {field_name}"
                    )
                    
    def _print_results(self):
        """Print validation results"""
        print(f"\n{'='*60}")
        print("VALIDATION RESULTS")
        print(f"{'='*60}")
        print(f"Rules validated: {self.rules_validated}")
        print(f"Unique rule IDs: {len(self.rule_ids)}")
        print(f"Errors: {len(self.errors)}")
        print(f"Warnings: {len(self.warnings)}")
        
        if self.errors:
            print(f"\n{'ERRORS:':-^60}")
            for error in self.errors:
                print(f" {error}")
                
        if self.warnings:
            print(f"\n{'WARNINGS:':-^60}")
            for warning in self.warnings:
                print(f"  {warning}")
                
        if not self.errors and not self.warnings:
            print("\n All validation checks passed!")
        elif not self.errors:
            print("\n No errors found (warnings can be addressed)")
        else:
            print("\n Validation failed - please fix errors above")
            
        print(f"{'='*60}\n")


def main():
    """Main entry point"""
    # Default to rules directory
    rules_dir = Path(__file__).parent.parent / 'rules'
    rules_file = rules_dir / 'custom_detection_rules.xml'
    
    # Allow command line argument
    if len(sys.argv) > 1:
        rules_file = Path(sys.argv[1])
        
    validator = RuleValidator(str(rules_file))
    success = validator.validate()
    
    # Exit with appropriate code for CI/CD
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()