classdef UAC_BarringInfo
    properties

    uac_BarringInfoSetList UAC_BarringInfoSet
    
    end
    
    methods
        %Конструктор
        function obj = UAC_BarringInfo(varargin) %varargin - cell-массив, специальная переменная в MATLAB, 
            % используемая для обработки произвольного количества входных аргументов
            obj.uac_BarringInfoSetList = UAC_BarringInfoSet.empty(); %инициализация пустым массивом
            if nargin > 0 %число переданных аргументов не 0
                obj = obj.addElements(varargin{:}); %если при создании объекта создаются элементы в виде массивов
                %то вызывается функция добавления элементов, в которую распаковываются значения varargin
            end
        end
        
        %Метод добавления элементов (без явной проверки типа)
        function obj = addElements(obj, varargin) % аргументами являются объект, к которому добавляются значения 
            % и сами значения
            if numel(obj.uac_BarringInfoSetList) + numel(varargin) > 8 %проверка не выйдем ли за пределы 
                error('Maximum 8 elements allowed');
            else
                obj.uac_BarringInfoSetList(end+1:end+numel(varargin)) = [varargin{:}]; %указание на какие позиции добавляются 
                % элементы, распаковка элементов из varargin и компановка в массивы
            end
        end
        
    end
end